/**
 * @author O. Berehovskyi
 * @see Hashids
 */
@IsTest(IsParallel = true)
public class HashidsTest {
    
    private static final String TEST_SALT = 'this is my salt';
    private static final Hashids HASHIDS = new Hashids(TEST_SALT);
    
    @IsTest
    static void shouldEncodeSingleInt() {
        System.assertEquals('NV', HASHIDS.encode(1));
        System.assertEquals('K4', HASHIDS.encode(22));
        System.assertEquals('OqM', HASHIDS.encode(333));
        System.assertEquals('kQVg', HASHIDS.encode(9999));
        System.assertEquals('58LzD', HASHIDS.encode(123000));
        System.assertEquals('5gn6mQP', HASHIDS.encode(456000000));
        System.assertEquals('oyjYvry', HASHIDS.encode(987654321));
    }

    @IsTest
    static void shouldDecodeSingleInt() {
        System.assertEquals(new List<Long>{ 1 }, HASHIDS.decode('NV'));
        System.assertEquals(new List<Long>{ 22 }, HASHIDS.decode('K4'));
        System.assertEquals(new List<Long>{ 333 }, HASHIDS.decode('OqM'));
        System.assertEquals(new List<Long>{ 9999 }, HASHIDS.decode('kQVg'));
        System.assertEquals(new List<Long>{ 123000 }, HASHIDS.decode('58LzD'));
        System.assertEquals(new List<Long>{ 456000000 }, HASHIDS.decode('5gn6mQP'));
        System.assertEquals(new List<Long>{ 987654321 }, HASHIDS.decode('oyjYvry'));
    }

    @IsTest
    static void shouldEncodeSingleLong() {
        System.assertEquals('NV', HASHIDS.encode(1L));
        System.assertEquals('21OjjRK', HASHIDS.encode(2147483648L));
        System.assertEquals('D54yen6', HASHIDS.encode(4294967296L));
        System.assertEquals('KVO9yy1oO5j', HASHIDS.encode(666555444333222L));
        System.assertEquals('4bNP1L26r', HASHIDS.encode(12345678901112L));
        System.assertEquals('262mm1m4J9Z', HASHIDS.encode(9007199254740992L));
    }

    @IsTest
    static void shouldDecodeSingleLong() {
        System.assertEquals(new List<Long>{ 1L }, HASHIDS.decode('NV'));
        System.assertEquals(new List<Long>{ 2147483648L }, HASHIDS.decode('21OjjRK'));
        System.assertEquals(new List<Long>{ 4294967296L }, HASHIDS.decode('D54yen6'));
        System.assertEquals(new List<Long>{ 666555444333222L }, HASHIDS.decode('KVO9yy1oO5j'));
        System.assertEquals(new List<Long>{ 12345678901112L }, HASHIDS.decode('4bNP1L26r'));
        System.assertEquals(new List<Long>{ 9007199254740992L }, HASHIDS.decode('262mm1m4J9Z'));
    }

    @IsTest
    static void shouldEncodeInts() {
        System.assertEquals('laHquq', HASHIDS.encode(new List<Integer>{ 1, 2, 3 }));
        System.assertEquals('44uotN', HASHIDS.encode(new List<Integer>{ 2, 4, 6 }));
        System.assertEquals('97Jun', HASHIDS.encode(new List<Integer>{ 99, 25 }));
        System.assertEquals('7xKhrUxm', HASHIDS.encode(new List<Integer>{ 1337, 42, 314 }));
        System.assertEquals('aBMswoO2UB3Sj', HASHIDS.encode(new List<Integer>{ 683, 94108, 123, 5 }));
        System.assertEquals('3RoSDhelEyhxRsyWpCx5t1ZK', HASHIDS.encode(new List<Integer>{ 547, 31, 241271, 311, 31397, 1129, 71129 }));
        System.assertEquals('p2xkL3CK33JjcrrZ8vsw4YRZueZX9k', HASHIDS.encode(new List<Integer>{ 21979508, 35563591, 57543099, 93106690, 150649789 }));
    }

    @IsTest
    static void shouldDecodeInts() {
        System.assertEquals(new List<Integer>{ 66655, 5444333, 2, 22 }, HASHIDS.decodeInt('1gRYUwKxBgiVuX'));
        System.assertEquals(new List<Integer>{ 683, 94108, 123, 5 }, HASHIDS.decodeInt('aBMswoO2UB3Sj'));
        System.assertEquals(new List<Integer>{ 3, 4 }, HASHIDS.decodeInt('jYhp'));
        System.assertEquals(new List<Integer>{ 6, 5 }, HASHIDS.decodeInt('k9Ib'));
        System.assertEquals(new List<Integer>{ 31, 41 }, HASHIDS.decodeInt('EMhN'));
        System.assertEquals(new List<Integer>{ 13, 89 }, HASHIDS.decodeInt('glSgV'));
    }

    @IsTest
    static void shouldEncodeLongs() {
        System.assertEquals('laHquq', HASHIDS.encode(new List<Long>{ 1L, 2L, 3L }));
        System.assertEquals('44uotN', HASHIDS.encode(new List<Long>{ 2L, 4L, 6L }));
        System.assertEquals('97Jun', HASHIDS.encode(new List<Long>{ 99L, 25L }));
        System.assertEquals('7xKhrUxm', HASHIDS.encode(new List<Long>{ 1337L, 42L, 314L }));
        System.assertEquals('aBMswoO2UB3Sj', HASHIDS.encode(new List<Long>{ 683L, 94108L, 123L, 5L }));
        System.assertEquals('3RoSDhelEyhxRsyWpCx5t1ZK', HASHIDS.encode(new List<Long>{ 547L, 31L, 241271L, 311L, 31397L, 1129L, 71129L }));
        System.assertEquals('p2xkL3CK33JjcrrZ8vsw4YRZueZX9k', HASHIDS.encode(new List<Long>{ 21979508L, 35563591L, 57543099L, 93106690L, 150649789L }));
        System.assertEquals('mPVbjj7yVMzCJL215n69', HASHIDS.encode(new List<Long>{ 666555444333222L, 12345678901112L }));
    }

    @IsTest
    static void shouldDecodeLongs() {
        System.assertEquals(new List<Long>{ 666555444333222L, 12345678901112L }, HASHIDS.decode('mPVbjj7yVMzCJL215n69'));
        System.assertEquals(new List<Long>{ 66655L, 5444333L, 2L, 22L }, HASHIDS.decode('1gRYUwKxBgiVuX'));
        System.assertEquals(new List<Long>{ 683L, 94108L, 123L, 5L }, HASHIDS.decode('aBMswoO2UB3Sj'));
        System.assertEquals(new List<Long>{ 3L, 4L }, HASHIDS.decode('jYhp'));
        System.assertEquals(new List<Long>{ 6, 5 }, HASHIDS.decode('k9Ib'));
        System.assertEquals(new List<Long>{ 31, 41 }, HASHIDS.decode('EMhN'));
        System.assertEquals(new List<Long>{ 13, 89 }, HASHIDS.decode('glSgV'));
    }
    
    @IsTest
    static void shouldRoundTrip() {
        List<Long> input1 = new List<Long>{ 66655L, 5444333L, 2L, 22L };
        List<Long> input2 = new List<Long>{ 683, 94108, 123, 5 };
        List<Long> input3 = new List<Long>{ 1L, 9007199254740992L };
        System.assertEquals(input1, HASHIDS.decode(HASHIDS.encode(input1)));
        System.assertEquals(input2, HASHIDS.decode(HASHIDS.encode(input2)));
        System.assertEquals(input3, HASHIDS.decode(HASHIDS.encode(input3)));
    }

    @IsTest
    static void shouldEncodeHex() {
        System.assertEquals('lzY', HASHIDS.encodeHex('FA'));
        System.assertEquals('MemE', HASHIDS.encodeHex('26dd'));
        System.assertEquals('eBMrb', HASHIDS.encodeHex('FF1A'));
        System.assertEquals('D9NPE', HASHIDS.encodeHex('12abC'));
        System.assertEquals('9OyNW', HASHIDS.encodeHex('185b0'));
        System.assertEquals('MRWNE', HASHIDS.encodeHex('17b8d'));
        System.assertEquals('4o6Z7KqxE', HASHIDS.encodeHex('1d7f21dd38'));
        System.assertEquals('ooweQVNB', HASHIDS.encodeHex('20015111d'));
    }

    @IsTest
    static void shouldDecodeHex() {
        System.assertEquals('fa', HASHIDS.decodeHex('lzY'));
        System.assertEquals('26dd', HASHIDS.decodeHex('MemE'));
        System.assertEquals('ff1a', HASHIDS.decodeHex('eBMrb'));
        System.assertEquals('12abc', HASHIDS.decodeHex('D9NPE'));
        System.assertEquals('185b0', HASHIDS.decodeHex('9OyNW'));
        System.assertEquals('17b8d', HASHIDS.decodeHex('MRWNE'));
        System.assertEquals('1d7f21dd38', HASHIDS.decodeHex('4o6Z7KqxE'));
        System.assertEquals('20015111d', HASHIDS.decodeHex('ooweQVNB'));
    }

    @IsTest
    static void shouldRoundTripHex() {
        String input1 = 'DEADBEEF';
        String input2 = '1234567890ABCDEF';
        System.assertEquals(input1.toLowerCase(), HASHIDS.decodeHex(HASHIDS.encodeHex(input1)));
        System.assertEquals(input2.toLowerCase(), HASHIDS.decodeHex(HASHIDS.encodeHex(input2)));
    }

    @IsTest
    static void shouldNotProduceSimilarPattern() {
        System.assertEquals('1Wc8cwcE', HASHIDS.encode(new List<Long>{ 5, 5, 5, 5 }));
        System.assertEquals('kRHnurhptKcjIDTWC3sx', HASHIDS.encode(new List<Long>{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }));
        System.assertEquals('NV', HASHIDS.encode(1));
        System.assertEquals('6m', HASHIDS.encode(2));
        System.assertEquals('yD', HASHIDS.encode(3));
        System.assertEquals('2l', HASHIDS.encode(4));
        System.assertEquals('rD', HASHIDS.encode(5));
    }

    @IsTest
    static void shouldRoundTripWhenInputWithZero() {
        List<Long> input1 = new List<Long>{ 1, 2, 0 };
        List<Long> input2 = new List<Long>{ 0, 1, 2 };
        System.assertEquals(input1, HASHIDS.decode(HASHIDS.encode(input1)));
        System.assertEquals(input2, HASHIDS.decode(HASHIDS.encode(input2)));
    }

    @IsTest
    static void shouldReturnEmptyStringWhenNoNumbersInput() {
        System.assertEquals('', HASHIDS.encode((Long) null));
        System.assertEquals('', HASHIDS.encode((Integer) null));
        System.assertEquals('', HASHIDS.encode(new List<Long>{ null }));
        System.assertEquals('', HASHIDS.encode(new List<Integer>{ null }));
    }

    @IsTest
    static void shouldReturnEmptyStringWhenNegativeNumbersInput() {
        System.assertEquals('', HASHIDS.encode(new List<Long>{ 1, -3 }));
        System.assertEquals('', HASHIDS.encode(new List<Integer>{ -3, 0 }));
    }

    @IsTest
    static void shouldReturnEmptyStringWhenInvalidHexInput() {
        System.assertEquals('', HASHIDS.encodeHex('XYZ123'));
    }

    @IsTest
    static void shouldEncodeWithMinHashLength() {
        Integer minHashLength = 18;
        Hashids hashids = new Hashids(TEST_SALT, minHashLength);
        System.assert(hashids.encode(1).length() >= minHashLength);
        System.assert(hashids.encode(new List<Long>{ 4140, 21147, 115975, 678570, 4213597, 27644437 }).length() >= minHashLength);
        System.assertEquals('aJEDngB0NV05ev1WwP', hashids.encode(1));
        System.assertEquals('pLMlCWnJSXr1BSpKgqUwbJ7oimr7l6', hashids.encode(new List<Long>{ 4140, 21147, 115975, 678570, 4213597, 27644437 }));
    }

    @IsTest
    static void shouldDecodeWithMinHashLength() {
        Integer minHashLength = 8;
        Hashids hashids = new Hashids(TEST_SALT, minHashLength);
        System.assertEquals(new List<Long>{ 1 }, hashids.decode('gB0NV05e'));
        System.assertEquals(new List<Long>{ 25, 100, 950 }, hashids.decode('mxi8XH87'));
        System.assertEquals(new List<Long>{ 5, 200, 195, 1 }, hashids.decode('KQcmkIW8hX'));
    }

    @IsTest
    static void shouldThrowArgumentExceptionWhenAlphabetContainsLessThan4UniqueChars() {
        try {
            new Hashids(TEST_SALT, 8, 'aadsss');
        } catch (Exception exc) {
            System.assertEquals('System.IllegalArgumentException', exc.getTypeName());
        }
    }

    @IsTest
    static void shouldThrowArgumentExceptionWhenAlphabetLessThanMinHashLength() {
        try {
            new Hashids(TEST_SALT, 8, 'abcdefghijklmno');
        } catch (Exception exc) {
            System.assertEquals('System.IllegalArgumentException', exc.getTypeName());
        }
    }

    @IsTest
    static void shouldThrowArgumentExceptionWhenNullAlphabet() {
        try {
            new Hashids(TEST_SALT, 8, null);
        } catch (Exception exc) {
            System.assertEquals('System.IllegalArgumentException', exc.getTypeName());
        }
    }

    @IsTest
    static void shouldRoundTripWhenAlphabetWithDashes() {
        String alphabet = 'abcdefghijklmnopqrstuvwxyz1234567890_-';
        Hashids hashids = new Hashids(TEST_SALT, 0, alphabet);
        List<Long> input1 = new List<Long>{ 1, 2, 3 };
        List<Long> input2 = new List<Long>{ 1, 2, 0 };
        System.assertEquals(input1, hashids.decode(hashids.encode(input1)));
        System.assertEquals(input2, hashids.decode(hashids.encode(input2)));
    }

    @IsTest
    static void shouldEncodeWithDefaultSalt() {
        Hashids hashids = new Hashids();
        System.assertEquals('o2fXhV', hashids.encode(new List<Long>{ 1, 2, 3 }));
    }

    @IsTest
    static void shouldReturnEmptyListWhenDifferentSalt() {
        System.assertEquals(new List<Long>{ 12345 }, HASHIDS.decode('NkK9'));
        System.assertEquals(new List<Long>(), new Hashids('different salt').decode('NkK9'));
    }

    @IsTest
    static void shouldRoundTripWhenCustomAlphabet() {
        Hashids hashids = new Hashids(TEST_SALT, 0, 'ABCDEFGhijklmn34567890-:');
        Hashids hashids1 = new Hashids(TEST_SALT, 0, 'ABCDEFGHIJKMNOPQRSTUVWXYZ23456789');
        Hashids hashids2 = new Hashids(TEST_SALT, 0, '0123456789abcdef');
        List<Long> input = new List<Long>{ 1, 2, 3, 4, 5 };
        List<Long> input1 = new List<Long>{ 1234567L };
        System.assertEquals(input, hashids.decode(hashids.encode(input)));
        System.assertEquals(input, hashids1.decode(hashids1.encode(input)));
        System.assertEquals(input1, hashids2.decode(hashids2.encode(input1)));
    }

    @IsTest
    static void shouldRoundTripWhenSaltIsLongerThanAlphabet() {
        Hashids hashids = new Hashids('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'.repeat(2));
        List<Long> input = new List<Long>{ 1, 2, 0 };
        System.assertEquals(input, hashids.decode(hashids.encode(input)));
    }

    @IsTest
    static void shouldReturnEmptyListWhenGuardCharacterOnly() {
        System.assertEquals(new List<Long>(), new Hashids().decode('a'));
    }

}
