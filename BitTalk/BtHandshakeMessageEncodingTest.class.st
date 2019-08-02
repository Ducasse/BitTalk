"
A BtHandshakeMessageTest is a test class for testing the behavior of BtHandshakeMessage
"
Class {
	#name : #BtHandshakeMessageEncodingTest,
	#superclass : #TestCase,
	#category : #'BitTalk-Tests'
}

{ #category : #tests }
BtHandshakeMessageEncodingTest >> testDecoding [
	| stream peerID infoHash handshake behaviour |
	behaviour := BtProtocolBehaviour new.
	infoHash := 12345678901234567890.
	peerID := 'qwertyuiopa' asByteArray asInteger.
	stream := WriteStream with: ByteArray new.
	stream
		nextPut: BtHandshakeMessage protocolIdentifier size;
		nextPutAll: BtHandshakeMessage protocolIdentifier asByteArray;
		nextPutAll: behaviour asByteArray;
		nextPutAll: (infoHash asByteArrayOfSize: 20);
		nextPutAll: (peerID asByteArrayOfSize: 20).
	handshake := stream contents decodeHandshake.
	self
		assert: handshake protocolIdentifier = BtHandshakeMessage protocolIdentifier;
		assert: handshake protocolBehaviour = behaviour;
		assert: handshake infoHash = infoHash;
		assert: handshake peerID = peerID
]

{ #category : #tests }
BtHandshakeMessageEncodingTest >> testEncoding [
	| infoHash peerID handshake stream |
	infoHash := (2 raisedTo: 160) - 1 atRandom.
	peerID := (2 raisedTo: 160) - 1 atRandom.
	handshake := BtHandshakeMessage new.
	handshake
		protocolIdentifier: BtHandshakeMessage protocolIdentifier;
		protocolBehaviour: BtProtocolBehaviour new;
		infoHash: infoHash;
		peerID: peerID.
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: BtHandshakeMessage protocolIdentifier size asByteArray;
		nextPutAll: BtHandshakeMessage protocolIdentifier asByteArray;
		nextPutAll: BtProtocolBehaviour new asByteArray;
		nextPutAll: (infoHash asByteArrayOfSize: 20);
		nextPutAll: (peerID asByteArrayOfSize: 20).
	self assert: handshake asByteArray = stream contents
]
