// Generated by CoffeeScript 1.12.4
(function() {
  var _, forge, rest;

  rest = require('./rest.coffee');

  forge = require('node-forge');

  _ = require('lodash');

  module.exports = function(opts) {
    if (opts == null) {
      opts = {};
    }
    return {
      encrypt: function(receiverEmail, message) {
        var cipher, encryptedMessage, key;
        key = forge.random.getBytesSync(opts.keySize);
        cipher = forge.cipher.createCipher(opts.algorithm, key);
        cipher.start;
        cipher.update(forge.util.createBuffer(message));
        cipher.finish;
        encryptedMessage = cipher.output.getBytes;
        return rest.get(opts.serverurl + "/api/user/" + receiverEmail).then(function(result) {
          var cert, encryptedKey, publicKey;
          cert = _.last(result.body.certs);
          publicKey = forge.pki.publicKeyFromPem(cert.publicKey);
          encryptedKey = publicKey.encrypt(key);
          return {
            encryptedMessage: encryptedMessage,
            encryptedKey: encryptedKey
          };
        });
      },
      decrypt: function(privateKey, bundle) {
        var cipher, encryptedKey, encryptedMessage, key;
        encryptedMessage = bundle.encryptedMessage;
        encryptedKey = bundle.encryptedKey;
        key = privateKey.decrypt(encryptedKey);
        cipher = forge.cipher.createDecipher(opts.algorithm, key);
        cipher.start();
        cipher.update(forge.util.createBuffer(encryptedMessage));
        if (!cipher.finish()) {
          throw new Error('Decryption failed');
        }
        return cipher.output.getBytes();
      }
    };
  };

}).call(this);
