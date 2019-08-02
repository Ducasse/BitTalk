Class {
	#name : #BtUDPPacketEncodingTest,
	#superclass : #TestCase,
	#instVars : [
		'connectRequest',
		'announceRequest',
		'scrapeRequest',
		'connectTransactionID',
		'announceTransactionID',
		'scrapeTransactionID',
		'errorTransactionID',
		'connectionID',
		'bytesConnectResponse',
		'bytesAnnounceResponse',
		'bytesScrapeResponse',
		'bytesErrorResponse',
		'firstConnectionID',
		'connectTransaction',
		'announceTransaction',
		'scrapeTransaction',
		'errorTransaction'
	],
	#category : #'BitTalk-Tests'
}

{ #category : #running }
BtUDPPacketEncodingTest >> setUp [
	connectTransactionID := 123456789.
	announceTransactionID := 746384.
	scrapeTransactionID := 931761.
	errorTransactionID := 9426715.
	connectionID := 627894364.
	firstConnectionID := BtUDPPacket firstConnectionID.
	connectTransaction := BtUDPTransaction new.
	connectTransaction actionCode: 0.
	connectTransaction id: connectTransactionID.
	announceTransaction := BtUDPTransaction new.
	announceTransaction actionCode: 1.
	announceTransaction id: announceTransactionID.
	scrapeTransaction := BtUDPTransaction new.
	scrapeTransaction actionCode: 2.
	scrapeTransaction id: scrapeTransactionID.
	self setUpDecoded.
	self setUpEncoded
]

{ #category : #running }
BtUDPPacketEncodingTest >> setUpDecoded [
	connectRequest := BtUDPConnectRequest new.
	connectRequest connectionID: firstConnectionID.
	connectRequest transaction: connectTransaction.
	announceRequest := BtUDPAnnounceRequest new.
	announceRequest connectionID: connectionID.
	announceRequest transaction: announceTransaction.
	scrapeRequest := BtUDPScrapeRequest new.
	scrapeRequest connectionID: connectionID.
	scrapeRequest transaction: scrapeTransaction.
	scrapeRequest infoHashCollection addAll: #(0 1 2 3)
]

{ #category : #running }
BtUDPPacketEncodingTest >> setUpEncoded [
	| stream |
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: (0 asByteArrayOfSize: 4);
		nextPutAll: (connectTransactionID asByteArrayOfSize: 4);
		nextPutAll: (connectionID asByteArrayOfSize: 8).
	bytesConnectResponse := stream contents.
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: (1 asByteArrayOfSize: 4);
		nextPutAll: (announceTransactionID asByteArrayOfSize: 4);
		nextPutAll: (0 asByteArrayOfSize: 4);
		nextPutAll: (0 asByteArrayOfSize: 4);
		nextPutAll: (0 asByteArrayOfSize: 4).
	bytesAnnounceResponse := stream contents.
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: (2 asByteArrayOfSize: 4);
		nextPutAll: (scrapeTransactionID asByteArrayOfSize: 4).
	bytesScrapeResponse := stream contents.
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: (3 asByteArrayOfSize: 4);
		nextPutAll: (errorTransactionID asByteArrayOfSize: 4).
	bytesErrorResponse := stream contents.	
]

{ #category : #tests }
BtUDPPacketEncodingTest >> testDecoding [
	| connectResponse announceResponse scrapeResponse  errorResponse |
	connectResponse := BtUDPConnectResponse new.
	connectResponse transaction: connectTransaction.
	connectResponse connectionID: connectionID.
	self assert: connectResponse = bytesConnectResponse decodeUDPResponse.
	announceResponse := BtUDPAnnounceResponse new.
	announceResponse transaction: announceTransaction.
	self assert: announceResponse = bytesAnnounceResponse decodeUDPResponse.	
	scrapeResponse := BtUDPScrapeResponse new.
	scrapeResponse transaction: scrapeTransaction.
	self assert: scrapeResponse = bytesScrapeResponse decodeUDPResponse.
	errorResponse := BtUDPErrorResponse new.
	errorResponse transaction: errorTransaction.
	self assert: errorResponse = bytesErrorResponse decodeUDPResponse.		
]

{ #category : #tests }
BtUDPPacketEncodingTest >> testEncoding [
	| stream |
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: (BtUDPPacket firstConnectionID asByteArrayOfSize: 8);
		nextPutAll: (0 asByteArrayOfSize: 4);
		nextPutAll: (connectTransactionID asByteArrayOfSize: 4).
	self assert: connectRequest asByteArray = stream contents.
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: (connectionID asByteArrayOfSize: 8);
		nextPutAll: (1 asByteArrayOfSize: 4);
		nextPutAll: (announceTransactionID asByteArrayOfSize: 4);
		nextPutAll: (ByteArray new: 82).
	self assert: announceRequest asByteArray = stream contents.	
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: (connectionID asByteArrayOfSize: 8);
		nextPutAll: (2 asByteArrayOfSize: 4);
		nextPutAll: (scrapeTransactionID asByteArrayOfSize: 4);
		nextPutAll: (0 asByteArrayOfSize: 20);
		nextPutAll: (1 asByteArrayOfSize: 20);
		nextPutAll: (2 asByteArrayOfSize: 20);
		nextPutAll: (3 asByteArrayOfSize: 20).
	self assert: scrapeRequest asByteArray = stream contents.			
	
]
