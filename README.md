# Hashids

Hashids is small Apex library to generate YouTube-like ids from numbers (`Integers` or `Longs`) or from hexadecimal `Strings`.

It converts numbers like `347` into strings like `yr8`, or list of numbers like `[27, 986]` into `3kTMd`.
It is also possible to decode those ids back.
This is useful in bundling several parameters into one, hiding actual IDs, or simply using them as short IDs.

## Features

- Creates short unique ids from non-negative numbers (`Integers` or `Longs`).
- Supports single number (`Integer` or `Long`) as well as hex `Strings` (e.g. `1d7f21dd38`).
- Generates YouTube-like non-sequential IDs to stay unguessable.
- Allows custom alphabet as well as salt — so ids are unique only to you *(salt must be smaller than alphabet)*.
- Allows specifying minimum hash length.
- Tries to avoid basic English curse words.

**NOTE**: *This is **NOT** true encryption algorithm, since it is reversible. Please do **NOT** encode sensitive data, 
like passwords or PINs.*

## Installation

<a href="https://githubsfdeploy.herokuapp.com?owner=berehovskyi&repo=apex-hashids&ref=master">
  <img alt="Deploy to Salesforce" src="https://img.shields.io/badge/Deploy%20to-Salesforce-%2300a1e0?style=for-the-badge&logo=appveyor">
</a>

## Usage

### Encoding one number

You can pass a unique `salt` value so your hashes differ from everyone else's:
```apex
final Hashids hashids = new Hashids('this is my salt');
final String hash = hashids.encode(123456); // 'NkK9'
```

`Long` numbers encoding is also supported (up to `9007199254740992L`):
```apex
final Hashids hashids = new Hashids('this is my salt');
final String hash = hashids.encode(666555444333222L); // 'KVO9yy1oO5j'
```

### Decoding

Notice during decoding, same salt value is used:
```apex
final Hashids hashids = new Hashids('this is my salt');
final List<Long> numbers1 = hashids.decode('NkK9'); // [12345L]
final List<Long> numbers2 = hashids.decode('KVO9yy1oO5j'); // [666555444333222L]
```

### Decoding with different salt

Decoding will not work if salt is changed:
```apex
final Hashids hashids = new Hashids('this is not my salt');
final List<Long> numbers = hashids.decode('NkK9'); // []
```

### Encoding several numbers

```apex
final Hashids hashids = new Hashids('this is my salt');
final String hash = hashids.encode(new List<Integer>{ 683, 94108, 123, 5 }); // 'aBMswoO2UB3Sj'
// Or
final String hash = hashids.encode(new List<Long>{ 683L, 94108L, 123L, 5L }); // 'aBMswoO2UB3Sj'
```

### Decoding is done the same way

The result of decoding by default is a `List<Long>`:
```apex
final Hashids hashids = new Hashids('this is my salt');
final List<Long> numbers = hashids.decode('aBMswoO2UB3Sj'); // [683, 94108, 123, 5]
```

It is also possible to decode the provided hash as `List<Integer>` safely 
if a decoded result list does not contain a number greater than `2147483647`:
```apex
final Hashids hashids = new Hashids('this is my salt');
final List<Integer> numbers = hashids.decodeInt('aBMswoO2UB3Sj'); // [683, 94108, 123, 5]
```

### Encoding and specifying minimum hash length

Here we encode integer `1`, and set the minimum hash length to `8`
(`0` by default -- meaning hashes will be the shortest possible length):
```apex
final Hashids hashids = new Hashids('this is my salt', 8);
final String hash = hashids.encode(1); // 'gB0NV05e'
```

### Decoding

```apex
final Hashids hashids = new Hashids('this is my salt', 8);
final List<Long> numbers = hashids.decode('gB0NV05e'); // [1]
```

### Specifying custom hash alphabet

Here we set the alphabet to consist of: `abcdefghijkABCDEFGHIJK12345`:
```apex
final Hashids hashids = new Hashids('this is my salt', 8, 'abcdefghijkABCDEFGHIJK12345');
final String hash = hashids.encode(new List<Integer>{ 1, 2, 3, 4, 5 }); // 'Ec4iEHeF3'
```

The default alphabet is `abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`.

## Randomness

The primary purpose of `hashids` is to obfuscate ids. 
It's not meant or tested to be used for security purposes or compression. 
Having said that, this algorithm does try to make these hashes unguessable and unpredictable:

### Repeating numbers

You don't see any repeating patterns that might show there's `4` identical numbers in the hash:
```apex
final Hashids hashids = new Hashids('this is my salt');
final String hash = hashids.encode(new List<Integer>{ 5, 5, 5, 5 }); // '1Wc8cwcE'
```

Same with incremented numbers:
```apex
final Hashids hashids = new Hashids('this is my salt');
final String hash = hashids.encode(new List<Integer>{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }); // 'kRHnurhptKcjIDTWC3sx'
```

### Incrementing number hashes

```apex
final Hashids hashids = new Hashids('this is my salt');
hashids.encode(1); // 'NV'
hashids.encode(2); // '6m'
hashids.encode(3); // 'yD'
hashids.encode(4); // '2l'
hashids.encode(5); // 'rD'
```

### Encoding a HEX String

HEX String encoding is case-insensitive:
```apex
final Hashids hashids = new Hashids('this is my salt');
final String hash = hashids.encodeHex('DEADBEEF'); // 'kRNrpKlJ'
// Or
final String hash = hashids.encodeHex('deadbeed'); // 'kRNrpKlJ'
```

### Decoding to a HEX String

And the result is going to only consist of lowercase hexadecimal digits:
```apex
final Hashids hashids = new Hashids('this is my salt');
final String hash = hashids.decodeHex('kRNrpKlJ'); // 'deadbeef'
```

### C**rses!

We need ids to be nice and friendly especially if they end up being in the URL.

Therefore, the algorithm tries to avoid generating most common English curse words 
by never placing the following letters (and their uppercase equivalents) next to each other:

`c, s, f, h, u, i, t`

### Collisions

There are no collisions because the method is based on `Integer` / `Long` to hash conversion. 
As long as you don't change constructor arguments midway, the generated output will stay unique to your salt.

## Apex Example

`Hashids` is useful when it comes to hiding actual `Ids` for example on a custom LWC page, 
through a rest resource, etc.

For instance, we can create an Apex Rest Resource which finds an `Account` by hashed `Id`:

```apex
@RestResource(UrlMapping = '/Account/*')
global inherited sharing class AccountResource {

    @HttpGet
    global static Account doGet() {
        // Parse hash from URL
        final String hashids = RestContext.request.requestURI.substringAfterLast('/');
        // Decode the input hash String into numbers
        final List<Integer> chars = new Hashids('this is my salt').decodeInt(hashids);
        // Convert the chars into Id
        final Id accountId = String.fromCharArray(chars);
        // Find Account by actual Id
        final Account result = [SELECT Name, Website FROM Account WHERE Id = :accountId];
        // Return a clone to hide an actual account Id
        return result.clone(false);
    }
}
```

If we want to encode a real `Id` of `SObject`:

```apex
final List<Integer> idChars = [SELECT Id FROM Account LIMIT 1] // Get any random account for example
        .Id // Get an Id field
        .to15() // Convert to a 15-character case-sensitive string 
        .getChars(); // Get a list of character values that represent the characters in this string

final String hash = new Hashids('this is my salt').encode(idChars); // 'WqbImVIa7TKMi4MuL7Iy8IDqI8oIbRIOWU8XImJtLrc8j'
```

Having that generated somehow hash we can execute the next http request to `AccountResource`:
```http request
GET {{instance_url}}/services/apexrest/Account/WqbImVIa7TKMi4MuL7Iy8IDqI8oIbRIOWU8XImJtLrc8j
Accept: application/json
Cache-Control: no-cache
Authorization: Bearer {{access_token}}
X-PrettyPrint: 1
Content-Type: application/json
```

The response:
```json
{
  "attributes": {
    "type": "Account"
  },
  "Name": "Sample Account",
  "Website": "https://hashids.org/"
}
```
