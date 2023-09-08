package com.interon.cryptography;

import javax.crypto.*;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.UnsupportedEncodingException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import java.util.Random;

public class Decipher {

    public String iscEncrypt(String message, String pKey, String piv) throws IllegalBlockSizeException {
        try {
            byte[] encKeyDecoded = Base64.getDecoder().decode(pKey.getBytes("UTF-8"));
            byte[] ivDecoded = Base64.getDecoder().decode(piv.getBytes("UTF-8"));
            SecretKey eKey = new SecretKeySpec(encKeyDecoded, "DESede");
            IvParameterSpec iv = new IvParameterSpec(ivDecoded);
            String msgCrypt = encrypt(message, eKey, iv);
            return msgCrypt;
        } catch (Exception e) {
            return "error" + e;
        }


    }

    public String iscDecrypt(String message, String pKey, String piv) throws IllegalBlockSizeException {
        try {
            byte[] ivDecoded = Base64.getDecoder().decode(piv.getBytes("UTF-8"));
            byte[] encKeyDecoded = Base64.getDecoder().decode(pKey.getBytes("UTF-8"));
            SecretKey eKey = new SecretKeySpec(encKeyDecoded, "DESede");
            IvParameterSpec iv = new IvParameterSpec(ivDecoded);
            String msgdeCrypt = decrypt(message, eKey, iv);
            return msgdeCrypt;
        } catch (Exception e) {
            return "error na descrypt " + e;
        }
    }

    public String createsIV() {
        IvParameterSpec iv = criaIvDummy();
        byte[] ivBytes = iv.getIV();
        // String novoIvEncoded = new String(Base64.getEncoder().encode(ivBytes));
        String newIV = Base64.getEncoder().encodeToString(ivBytes);
        return newIV;
    }

    public static IvParameterSpec criaIvDummy() {
        byte[] randomBytes = new byte[8];
        new Random().nextBytes(randomBytes);
        IvParameterSpec iV = new IvParameterSpec(randomBytes);
        return iV;

    }

    public String encrypt(String message, SecretKey key, IvParameterSpec iv) throws NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException, UnsupportedEncodingException, IllegalBlockSizeException, BadPaddingException {
        final Cipher cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, key, iv);
        byte[] plainTextBytes = message.getBytes("utf-8");
        byte[] buf = cipher.doFinal(plainTextBytes);
        byte[] base64Bytes = Base64.getEncoder().encode(buf);
        String base64EncryptedString = new String(base64Bytes);
        return base64EncryptedString;
    }

    public String decrypt(String encMessage, SecretKey key, IvParameterSpec iv) throws UnsupportedEncodingException, NoSuchAlgorithmException, NoSuchPaddingException, InvalidKeyException, IllegalBlockSizeException, BadPaddingException, InvalidAlgorithmParameterException {
        byte[] message = Base64.getDecoder().decode(encMessage.getBytes("utf-8"));
        final Cipher decipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
        decipher.init(Cipher.DECRYPT_MODE, key, iv);
        byte[] plainText = decipher.doFinal(message);
        return new String(plainText, "UTF-8");
    }
}
