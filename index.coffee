forge = require 'node-forge'
_ = require 'lodash'

			
# opts
# keySize: 32, 16 bytes will use AES-128, 24 => AES-192, 32 => AES-256
# Algorithm : AES-CBC			

module.exports = (opts = {}) ->

	_.defaults opts, {keySize: 32, algorithm: 'AES-CBC'}

	encrypt: (pubkey, message) ->
		# Generate Symmetric key		
		key = forge.random.getBytesSync opts.keySize
		iv = forge.random.getBytesSync opts.keySize

		# Encrypt message
		cipher = forge.cipher.createCipher opts.algorithm, key
		cipher.start iv:iv
		cipher.update forge.util.createBuffer message
		cipher.finish()

		# Encrypt symmetric key with receiver public key
		return {
			encryptedMessage: cipher.output.getBytes()
			encryptedKey: (forge.pki.publicKeyFromPem pubkey).encrypt(key)
			iv: iv
		}

	decrypt: (prikey, bundle) ->
		# Decrypt symmetric key with receiver private key and message
		cipher = forge.cipher.createDecipher opts.algorithm, (forge.pki.privateKeyFromPem(prikey)).decrypt bundle.encryptedKey
		cipher.start iv:bundle.iv
		cipher.update forge.util.createBuffer bundle.encryptedMessage
		if !cipher.finish()
			throw new Error 'Decryption failed'
		return cipher.output.getBytes()

	# Defaults Alogrithm to RSASSA PKCS #1 v1.5 	
	sign: (prikey, message) ->
		# sign data with a private key
		md = forge.md.sha256.create();
		md.update message, 'utf8'
		signature = (forge.pki.privateKeyFromPem prikey).sign md
		
		return {
			md: md
			signature: signature
		}
		
	verify: (pubkey, bundle) ->
		# Verify data with a public key
		return (forge.pki.publicKeyFromPem pubkey).verify (bundle.md).digest().bytes(), bundle.signature	
		
		