/**
 * @author O. Berehovskyi
 * @description A class to generate YouTube-like hashes from one or many numbers.
 * @example 
 * HashIds hashids = new HashIds();
 * String hash = hashids.encode(12345); // 'NkK9'
 * List<Long> numbers = hashids.decode(hash); // [12345]
 */
public inherited sharing class Hashids {

    private static final String DEFAULT_ALPHABET
            = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    private static final String DEFAULT_SEPS = 'cfhistuCFHISTU';
    private static final String DEFAULT_SALT = '';
    private static final String HEX_PATTERN = '^[0-9a-fA-F]+$';
    private static final String HEX_SPLITTER = '[\\w\\W]{1,12}';
    private static final String HEX_DIGITS = '0123456789abcdef';
    private static final String EMPTY_STRING = '';

    private static final Long MAX_LONG = 9007199254740992L;
    private static final Integer MIN_ALPHABET_LENGTH = 16;
    private static final Double SEP_DIV = 3.5;
    private static final Double GUARD_DIV = 12.0;

    private static final Validate VALIDATE = new Validate();
    private static final Chars CHARS = new Chars();
    private static final Convert CONVERT = new Convert();

    private final List<Integer> alphabet;
    private final List<Integer> seps;
    private final List<Integer> guards;
    private final List<Integer> salt;
    private final Integer minHashLength;
    
    private static final List<Long> EMPTY_LIST { get { return new List<Long>(); } }

    /**
     * @description Constructs new Hashids encoder/decoder instance 
     * with default seps = 'cfhistuCFHISTU' and 
     * default alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890' and
     * default minHashLength = 0 and 
     * default salt = ''.
     * @example 
     * Hashids hashids = new Hashids();
     */
    public Hashids() {
        this(DEFAULT_SALT);
    }

    /**
     * @description Constructs new Hashids encoder/decoder instance 
     * with default seps = 'cfhistuCFHISTU' and 
     * default alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890' and
     * default minHashLength = 0.
     * @param salt the string influencing generated hash ids
     * @example 
     * Hashids hashids = new Hashids('this is my salt');
     */
    public Hashids(final String salt) {
        this(salt, 0);
    }

    /**
     * @description Constructs new Hashids encoder/decoder instance 
     * with default seps = 'cfhistuCFHISTU' and 
     * default alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'.
     * @param salt the string influencing generated hash ids
     * @param minHashLength the minimum length for generated hashes
     * @example 
     * Hashids hashids = new Hashids('this is my salt', 8);
     */
    public Hashids(final String salt, final Integer minHashLength) {
        this(salt, minHashLength, DEFAULT_ALPHABET);
    }

    /**
     * @description Constructs new Hashids encoder/decoder instance 
     * with default seps = 'cfhistuCFHISTU'.
     * @param salt the string influencing generated hash ids
     * @param minHashLength the minimum length for generated hashes
     * @param alphabet the characters to use for generated hash ids
     * @example 
     * Hashids hashids = new Hashids(
     *     'this is my salt',
     *     8,
     *     'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
     * );
     */
    public Hashids(final String salt, final Integer minHashLength, final String alphabet) {
        this(salt, minHashLength, alphabet, DEFAULT_SEPS);
    }

    /**
     * @description Constructs new Hashids encoder/decoder instance.
     * @param salt the string influencing generated hash ids
     * @param minHashLength the minimum length for generated hashes
     * @param alphabet the characters to use for generated hash ids
     * @param seps the separators
     * @throws NullPointerException if `salt` is null
     * @throws IllegalArgumentException if `minHashLength` is less than `0`
     * or `alphabet` is blank, or `seps` is blank
     * @throws IllegalArgumentException if `alphabet` length is less than `16`
     * @throws IllegalArgumentException if `alphabet` contains empty spaces
     * @example 
     * Hashids hashids = new Hashids(
     *     'this is my salt',
     *     8, 
     *     'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
     *     'cfhistuCFHISTU'
     * );
     */
    public Hashids(final String salt, final Integer minHashLength, final String alphabet, final String seps) {
        VALIDATE.notNull(salt);
        VALIDATE.isTrue(minHashLength >= 0, Label.ArgumentNegativeErrorMessage);
        VALIDATE.isTrue(String.isNotBlank(alphabet));
        VALIDATE.isTrue(String.isNotBlank(seps));

        List<Integer> saltTmp = salt.trim().getChars();
        List<Integer> alphabetTmp = CHARS.distinct(alphabet.getChars());
        List<Integer> sepsTmp = seps.getChars();

        VALIDATE.isTrue(
                alphabetTmp.size() >= MIN_ALPHABET_LENGTH, 
                Label.AlphabetMustContainAtLeastUniqueCharsErrorMessage,
                new List<Object>{ MIN_ALPHABET_LENGTH }
        );
        VALIDATE.isTrue(!alphabetTmp.contains(' '.charAt(0)), Label.AlphabetCannotContainSpacesErrorMessage);
        
        // Separator characters can only be chosen from the characters in the alphabet
        sepsTmp = CHARS.intersect(sepsTmp, alphabetTmp);

        // Once separator characters are chosen, they must be removed from the alphabet available for hash generation
        alphabetTmp = CHARS.except(alphabetTmp, sepsTmp);

        VALIDATE.isTrue(
                alphabetTmp.size() >= MIN_ALPHABET_LENGTH - 6,
                Label.AlphabetMustContainAtLeastUniqueCharsNotPresentErrorMessage,
                new List<Object>{ MIN_ALPHABET_LENGTH }
        );

        sepsTmp = consistentShuffle(sepsTmp, saltTmp);

        if ((sepsTmp.isEmpty()) || (((Double) alphabetTmp.size() / sepsTmp.size()) > SEP_DIV)) {
            Integer sepsSize = (Integer) Math.ceil(alphabetTmp.size() / SEP_DIV);
            if (sepsSize == 1) {
                sepsSize++;
            }

            if (sepsSize > sepsTmp.size()) {
                final Integer diff = sepsSize - sepsTmp.size();
                sepsTmp.addAll(CHARS.slice(alphabetTmp, 0, diff));
                alphabetTmp = CHARS.slice(alphabetTmp, diff);
            } else {
                sepsTmp = CHARS.slice(sepsTmp, 0, sepsSize);
            }
        }

        alphabetTmp = consistentShuffle(alphabetTmp, saltTmp);

        final Integer guardCount = (Integer) Math.ceil(alphabetTmp.size() / GUARD_DIV);
        
        List<Integer> guardsTmp = new List<Integer>();
        if (alphabetTmp.size() < 3) {
            guardsTmp = CHARS.slice(sepsTmp, 0, guardCount);
            sepsTmp = CHARS.slice(sepsTmp, guardCount);
        } else {
            guardsTmp = CHARS.slice(alphabetTmp, 0, guardCount);
            alphabetTmp = CHARS.slice(alphabetTmp, guardCount);
        }
        
        this.alphabet = alphabetTmp;
        this.salt = saltTmp;
        this.minHashLength = minHashLength;
        this.seps = sepsTmp;
        this.guards = guardsTmp;
    }

    /**
     * @description Encodes the input `numbers` into a hashed String.
     * @param numbers the List of non-negative Long numbers to encode
     * @return the hashed String
     * @example 
     * new Hashids('this is my salt').encode(new List<Long>{ 1L, 2L, 3L }); // 'laHquq'
     */
    public String encode(final List<Long> numbers) {
        return generateHash(numbers);
    }

    /**
     * @description Encodes the input `number` (of Long or Integer type) into a hashed String.
     * @param num the non-negative number to encode
     * @return the hashed String
     * @example 
     * new Hashids('this is my salt').encode(1); // 'NV'
     * new Hashids('this is my salt').encode(1L); // 'NV'
     */
    public String encode(final Long num) {
        return encode(new List<Long>{ num });
    }

    /**
     * @description Encodes the input `hex` String into a hashed String.
     * @param hex the hex String to encode
     * @return the hashed String
     * @example 
     * new Hashids('this is my salt').encodeHex('185b0'); // '9OyNW'
     */
    public String encodeHex(final String hex) {
        if (!Pattern.compile(HEX_PATTERN).matcher(hex).matches()) {
            return EMPTY_STRING;
        }
        
        final Matcher matcher = Pattern.compile(HEX_SPLITTER).matcher(hex);
        final List<Long> longs = EMPTY_LIST;
        while (matcher.find()) {
            longs.add(CONVERT.toLong('1' + matcher.group()));
        }

        return generateHash(longs);
    }

    /**
     * @description Decodes the input `hash` String into numbers.
     * @param hash hashed String to decode
     * @return the List of non-negative Longs
     * @example 
     * new Hashids('this is my salt').decode('NV') // [1L]
     */
    public List<Long> decode(final String hash) {
        return getNumbersFrom(hash);
    }

    /**
     * @description Decodes the input `hash` String into numbers.
     * @param hash hashed String to decode
     * @return the List of non-negative Integers
     * @throws IllegalArgumentException if result numbers contain a number greater than `2147483647`
     * @example 
     * new Hashids('this is my salt').decodeInt('NV') // [1]
     */
    public List<Integer> decodeInt(final String hash) {
        return CONVERT.toInts(getNumbersFrom(hash));
    }

    /**
     * @description Decodes the input `hash` String into a hex String.
     * @param hash hashed String to decode
     * @return The decoded hex String
     * @example 
     * new Hashids('this is my salt').decodeHex('9OyNW'); // '185b0'
     */
    public String decodeHex(final String hash) {
        final List<Integer> result = new List<Integer>();
        final List<Long> longs = this.decode(hash);

        for (Integer i = 0, size = longs.size(); i < size; i++) {
            result.addAll(CHARS.slice(CONVERT.toHexChars(longs[i]), 1));
        }
        
        return String.fromCharArray(result);
    }

    private String generateHash(final List<Long> numbers) {
        if (numbers == null || numbers.isEmpty() || numbers.contains(null)) {
            return EMPTY_STRING;
        }
        
        for (Integer i = 0, size = numbers.size(); i < size; i++) {
            if (numbers[i] < 0) {
                return EMPTY_STRING;
            }
            VALIDATE.isTrue(
                    numbers[i] <= MAX_LONG,
                    Label.NumberIsGreaterThenMaxLongErrorMessage,
                    new List<Object>{ MAX_LONG }
            );
        }
        
        Long numbersHashInt = 0;
        for (Integer i = 0, size = numbers.size(); i < size; i++) {
            numbersHashInt += Math.mod(numbers[i], i + 100);
        }
        List<Integer> alphabet = this.alphabet;
        
        final Integer lottery = alphabet[(Integer) Math.mod(numbersHashInt, alphabet.size())];
        List<Integer> charBuilder = new List<Integer>();
        charBuilder.add(lottery);
        
        for (Integer i = 0, size = numbers.size(); i < size; i++) {
            Long num = numbers[i];
            List<Integer> buffer = new List<Integer>();
            buffer.add(lottery);
            buffer.addAll(this.salt);
            buffer.addAll(alphabet);

            alphabet = consistentShuffle(alphabet, CHARS.slice(buffer, 0, alphabet.size()));

            final List<Integer> hashBuffer = hash(num, alphabet);

            charBuilder.addAll(hashBuffer);

            if (i + 1 < numbers.size()) {
                Long sepsIndex = 0;
                if (!hashBuffer.isEmpty()) {
                    num = Math.mod(num, hashBuffer[0] + i);
                    sepsIndex = Math.mod(num, this.seps.size());
                }
                charBuilder.add(this.seps[(Integer) sepsIndex]);
            }
        }

        List<Integer> tmpArr = new List<Integer>();
        
        if (charBuilder.size() < this.minHashLength) {
            Long guardIndex = Math.mod(numbersHashInt + charBuilder[0], this.guards.size());
            Integer guard = this.guards[(Integer) guardIndex];

            tmpArr.add(guard);
            tmpArr.addAll(charBuilder); 
            
            charBuilder = CHARS.extract(tmpArr);

            if (charBuilder.size() < this.minHashLength) {
                guardIndex = Math.mod(numbersHashInt + charBuilder[2], this.guards.size());
                guard = this.guards[(Integer) guardIndex];

                charBuilder.add(guard);
            }
        }
        
        final Integer halfSize = alphabet.size() / 2;
        
        while (charBuilder.size() < this.minHashLength) {
            alphabet = consistentShuffle(alphabet, alphabet);
            tmpArr.addAll(CHARS.slice(alphabet, halfSize));
            tmpArr.addAll(charBuilder);
            tmpArr.addAll(CHARS.slice(alphabet, 0, halfSize));
            charBuilder = CHARS.extract(tmpArr);
            
            final Integer excess = charBuilder.size() - this.minHashLength;
            
            if (excess > 0) {
                final Integer startIndex = excess / 2;
                charBuilder = CHARS.slice(charBuilder, startIndex, startIndex + this.minHashLength);
            }
        }

        return String.fromCharArray(charBuilder);
    }

    private List<Long> getNumbersFrom(String hash) {
        if (String.isBlank(hash)) {
            return EMPTY_LIST;
        }
        
        final List<Integer> validChars = new List<Integer>();
        validChars.addAll(this.alphabet);
        validChars.addAll(this.guards);
        validChars.addAll(this.seps);
        
        for (Integer i = 0, length = hash.length(); i < length; i++) {
            if (!validChars.contains(hash.charAt(i))) {
                return EMPTY_LIST;
            }
        }
        
        final List<Long> result = EMPTY_LIST;

        String hashBreakdown = hash.replaceAll(CHARS.format(this.guards), ' ');
        List<String> hashArray = hashBreakdown.split(' ');
        
        Integer i = 0;
        Integer hashArraySize = hashArray.size();
        if (hashArraySize == 3 || hashArraySize == 2) {
            i = 1;
        }

        if (hashArraySize > 0) {
            hashBreakdown = hashArray[i];
            if (String.isNotEmpty(hashBreakdown)) {
                final Integer lottery = hashBreakdown.charAt(0);

                hashArray = hashBreakdown
                        .substring(1)
                        .replaceAll(CHARS.format(this.seps), ' ')
                        .split(' ');
                
                List<Integer> alphabet = this.alphabet.clone();
                for (Integer j  = 0, size = hashArray.size(); j < size; j++) {
                    List<Integer> buffer = new List<Integer>();
                    buffer.add(lottery);
                    buffer.addAll(this.salt);
                    buffer.addAll(alphabet);

                    alphabet = consistentShuffle(alphabet, CHARS.slice(buffer, 0, alphabet.size()));
                    result.add(unhash(hashArray[j], alphabet));
                }
            }
        }
        
        // Regenerate hash from numbers and compare to given hash to ensure the correct parameters were used
        if (!generateHash(result).equals(hash)) {
            return EMPTY_LIST;
        }
        
        return result;
    }

    private static List<Integer> consistentShuffle(final List<Integer> alphabet, final List<Integer> salt) {
        if (salt.isEmpty()) {
            return alphabet;
        }
        
        Integer ch, j;
        final List<Integer> tmpArr = alphabet.clone();
        for (Integer i = tmpArr.size() - 1, v = 0, p = 0; i > 0; i--) {
            v = Math.mod(v, salt.size());
            ch = salt[v];
            p += ch;
            j = Math.mod(ch + v + p, i);
            final Integer tmp = tmpArr[j];
            tmpArr[j] = tmpArr[i];
            tmpArr[i] = tmp;
            v++;
        }
        
        return tmpArr;
    }

    private static List<Integer> hash(Long input, final List<Integer> alphabet) {
        final List<Integer> result = new List<Integer>();
        final Integer alphabetSize = alphabet.size();
        do {
            final Integer i = (Integer) Math.mod(input, alphabetSize);
            if (i >= 0 && i < alphabet.size()) {
                CHARS.append(result, alphabet[i]);
            }
            input /= alphabetSize;
        } while (input > 0);
        return result;
    }

    private static Long unhash(final String input, final List<Integer> alphabet) {
        Long result = 0;
        for (Integer i = 0, length = input.length(), size = alphabet.size(); i < length; i++) {
            result = result * size + alphabet.indexOf(input.charAt(i));
        }
        return result;
    }

    private inherited sharing class Convert {
        
        private List<Integer> toInts(final List<Long> numbers) {
            final List<Integer> result = new List<Integer>();
            for (Integer i = 0, size = numbers.size(); i < size; i++) {
                VALIDATE.isTrue(
                        numbers[i] == (Integer) numbers[i],
                        Label.OutOfRangeErrorMessage,
                        new List<Long>{ numbers[i] }
                );
                result.add(numbers[i].intValue());
            }
            return result;
        }

        private Long toLong(final String hex) {
            final List<String> hexValue = hex.split(EMPTY_STRING);
            Long result = 0;
            for (Integer j = 0, len = hexValue.size(); j < len; j++) {
                result = (result * 16) + HEX_DIGITS.indexOf(hexValue[j].toLowerCase());
            }
            return result;
        }

        private List<Integer> toHexChars(Long num) {
            final List<Integer> result = new List<Integer>();
            while (num > 0) {
                CHARS.append(result, HEX_DIGITS.charAt((Integer) Math.mod(num, 16)));
                num /= 16;
            }
            return result;
        }
        
    }

    private inherited sharing class Chars {
        
        private List<Integer> distinct(final List<Integer> chars) {
            final List<Integer> result = new List<Integer>();
            for (Integer i = 0, size = chars.size(); i < size; i++) {
                if (!result.contains(chars[i])) {
                    result.add(chars[i]);
                }
            }
            return result;
        }

        private List<Integer> intersect(final List<Integer> left, final List<Integer> right) {
            final List<Integer> result = new List<Integer>();
            for (Integer i = 0, size = left.size(); i < size; i++) {
                if (right.contains(left[i])) {
                    result.add(left[i]);
                }
            }
            return result;
        }

        private List<Integer> except(final List<Integer> left, final List<Integer> right) {
            final List<Integer> result = new List<Integer>();
            for (Integer i = 0, size = left.size(); i < size; i++) {
                if (!right.contains(left[i])) {
                    result.add(left[i]);
                }
            }
            return result;
        }

        private List<Integer> append(final List<Integer> chars, final Integer ch) {
            if (chars.isEmpty()) {
                chars.add(ch);
            } else {
                chars.add(0, ch);
            }
            return chars;
        }

        public List<Integer> slice(final List<Integer> chars, final Integer startIndex) {
            return slice(chars, startIndex, chars.size());
        }

        private List<Integer> slice(
                final List<Integer> chars,
                final Integer startIndex,
                final Integer endIndex
        ) {
            if (startIndex <= 0 && endIndex >= chars.size()) {
                return chars;
            }
            final List<Integer> result = new List<Integer>();
            for (Integer i = startIndex; i < endIndex; i++) {
                result.add(chars[i]);
            }
            return result;
        }

        private List<Integer> extract(final List<Integer> chars) {
            try {
                return chars.clone();
            } finally {
                chars.clear();
            }
        }

        private String format(final List<Integer> chars) {
            return String.format('[{0}]', new List<Object>{ String.fromCharArray(chars) });
        }
        
    }
    
    private inherited sharing class Validate {

        private void notNull(final Object o) {
            if (o == null) { throw new NullPointerException(); }
        }

        private void isTrue(final Boolean condition) {
            if (!condition) { throw new IllegalArgumentException(); }
        }

        private void isTrue(final Boolean condition, final String message) {
            if (!condition) { throw new IllegalArgumentException(message); }
        }

        private void isTrue(final Boolean condition, final String message, final List<Object> arguments) {
            if (!condition) { throw new IllegalArgumentException(String.format(message, arguments)); }
        }
        
    }

}
