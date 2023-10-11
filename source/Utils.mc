using Toybox.Math;
using Toybox.System;
using Toybox.Cryptography;
using Toybox.StringUtil;

function generateRandomString(length) {

    var text = "";
    var chars = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"];

    for (var i = 0; i < length; i++) {
        var unitInterval = generateUnitInterval() * chars.size();
        var index = unitInterval.toNumber();
        text += chars[index];
    }
    System.println(text);
    return text;
}

function generateUnitInterval() {
    var RAND_BASE = 0x7FFFFFFF;
    var rn = Math.rand().toDouble();
    var rnzo = rn / RAND_BASE;
    return rnzo;
}

function generateHash(string) {
    var stringByteArray = StringUtil.convertEncodedString(string, {
        :fromRepresentation=>StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
        :toRepresentation=>StringUtil.REPRESENTATION_BYTE_ARRAY
    });
    var hash = new Cryptography.Hash({ :algorithm=>Cryptography.HASH_SHA256 });
    hash.update(stringByteArray);
    var hashDigest = hash.digest();
    var hashString = StringUtil.convertEncodedString(hashDigest, {
        :fromRepresentation=>StringUtil.REPRESENTATION_BYTE_ARRAY,
        :toRepresentation=>StringUtil.REPRESENTATION_STRING_BASE64
    });
    System.println(hashString);
    return hashString;
}

function b64(string) {
    return StringUtil.encodeBase64(string);
}

function stringReplace(str, oldString, newString) {
    var result = str;

    while (true) {
        var index = result.find(oldString);

        if (index != null) {
            var index2 = index+oldString.length();
            result = result.substring(0, index) + newString + result.substring(index2, result.length());
        } else {
            return result;
        }
    }

    return null;
}

