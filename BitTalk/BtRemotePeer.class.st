"
A BtP2PConnection is xxxxxxxxx.

Instance Variables
	socketStream:		<Object>

socketStream
	- xxxxx

"
Class {
	#name : #BtRemotePeer,
	#superclass : #BtPeer,
	#instVars : [
		'socketStream',
		'acceptsMe',
		'bitfield',
		'downloaded',
		'uploaded',
		'lastMessageReceivedTime',
		'outMessageQueue',
		'isAccepted',
		'isInteresting',
		'isInterested',
		'inMessageQueue',
		'receiving',
		'sending',
		'isLucky',
		'peerLock',
		'lastBlockReceivedTime',
		'connectTimeout',
		'lastMessageSentTime',
		'lastUploaded',
		'startMeasuringTime',
		'lastDownloaded',
		'unfulfilledOutgoingRequests'
	],
	#category : #'BitTalk-P2P'
}

{ #category : #'instance creation' }
BtRemotePeer class >> on: socketStream [
	"Create a RemotePeer on a socketStream."
	| remotePeer  |
	remotePeer:= self new socketStream: socketStream binary.
	remotePeer domain: (BtDomain new address: socketStream remoteAddress asInteger ) .
	remotePeer port: socketStream remotePort asInteger . 
	remotePeer setTimeOut.
	^remotePeer
]

{ #category : #operations }
BtRemotePeer >> accept [
	self
		sendUnchoke;
		isAccepted: true
]

{ #category : #accessing }
BtRemotePeer >> acceptsMe [
	^peerLock critical: [ acceptsMe ]
]

{ #category : #accessing }
BtRemotePeer >> acceptsMe: anObject [
	peerLock critical: [ acceptsMe := anObject ]
]

{ #category : #accessing }
BtRemotePeer >> bitfield [
	^ peerLock critical: [ bitfield ]
]

{ #category : #accessing }
BtRemotePeer >> bitfield: anObject [
	peerLock critical: [ bitfield := anObject ]
]

{ #category : #operations }
BtRemotePeer >> cancel: aBlockRequest [
	peerLock
		critical: [ 
			self sendCancel: aBlockRequest pieceIndex begin: aBlockRequest offset length: aBlockRequest length.
			unfulfilledOutgoingRequests remove: aBlockRequest ifAbsent: [ nil ] ]
]

{ #category : #operations }
BtRemotePeer >> close [
	socketStream ifNotNil:[socketStream close]  

]

{ #category : #operations }
BtRemotePeer >> connect [
	self connectAttempts: 1.
]

{ #category : #operations }
BtRemotePeer >> connectAttempts: attempts [
	| t timeout |
	t := 0.
	timeout := connectTimeout.
	[ 
	self isConnected
		ifTrue: [ ^ self ].
	socketStream := SocketStream openConnectionToHost: domain address asIPv4 port: port timeout: timeout.
	socketStream binary.
	self setTimeOut ]
		on: ConnectionTimedOut
		do: [ :ex | 
			t := t + 1.
			timeout := timeout + 0.3.
			t < attempts
				ifTrue: [ ex retry ]
				ifFalse: [ ex return ] ].
	self isConnected
		ifFalse: [ ConnectionTimedOut signal ]
]

{ #category : #queues }
BtRemotePeer >> dequeueAndSendNextMessage [
	| nextMessageToSend |
	self ensureKeepAlive.
	nextMessageToSend := outMessageQueue nextOrNil.
	nextMessageToSend
		ifNotNil: [ 
			socketStream nextPutAllFlush: nextMessageToSend asByteArray.
			peerLock critical: [ lastMessageSentTime := Time millisecondClockValue ] ]
]

{ #category : #queues }
BtRemotePeer >> dequeueNextReceivedMessage [
	^ inMessageQueue nextOrNil
]

{ #category : #operations }
BtRemotePeer >> destroy [
	socketStream ifNotNil:[socketStream destroy]  

]

{ #category : #queues }
BtRemotePeer >> discardOutgoingBlocks [
	outMessageQueue discardAllPieces
]

{ #category : #queues }
BtRemotePeer >> discardUnfulfilledIncomingRequests [
	inMessageQueue discardAllRequests
]

{ #category : #queues }
BtRemotePeer >> discardUnfulfilledOutgoingRequests [
	outMessageQueue discardAllRequests
]

{ #category : #accessing }
BtRemotePeer >> domain: aDomain [
	super domain: aDomain.
	self updateProcessesNames .
]

{ #category : #'measuring rates' }
BtRemotePeer >> downloadRate [
	^ peerLock
		critical: [ 
			| display |
			display := BtByteRateDisplay new.
			display byteDisplay
				amount:
					([ (downloaded amount - lastDownloaded amount) / (Time millisecondsSince: startMeasuringTime) ]
						on: ZeroDivide
						do: [ :ex | ex return: 0 ]).
			display ]
]

{ #category : #accessing }
BtRemotePeer >> downloaded [
	^peerLock critical: [ downloaded ]
]

{ #category : #queues }
BtRemotePeer >> enqueue: message [
	outMessageQueue nextPut: message
]

{ #category : #operations }
BtRemotePeer >> ensureKeepAlive [
	self secondsSinceLastSentMessage > (BtMessage connectionTimeOut - 10) 
		ifTrue:[self sendKeepAlive ]
]

{ #category : #testing }
BtRemotePeer >> haveIRequested: aBlockRequest [
	^peerLock critical: [ unfulfilledOutgoingRequests includes: aBlockRequest ] 
]

{ #category : #accessing }
BtRemotePeer >> increaseDownloadedBy: amount [
	peerLock critical: [ downloaded increaseBy: amount ]
]

{ #category : #accessing }
BtRemotePeer >> increaseUploadedBy: amount [
	peerLock critical: [ uploaded increaseBy: amount ]
]

{ #category : #'initialize-release' }
BtRemotePeer >> initialize [
	super initialize.
	isAccepted:= false.
	isInteresting:= false.
	acceptsMe:= false.
	isInterested:= false.
	isLucky:= false.
	bitfield := nil.
	downloaded:= BtByteDisplay new.
	uploaded:= BtByteDisplay new.
	lastDownloaded := BtByteDisplay new.
	lastUploaded := BtByteDisplay new.
	startMeasuringTime := 0.
	connectTimeout := 0.3.
	self initializeProcesses .
	outMessageQueue := BtMessageQueue new.	
	inMessageQueue := BtMessageQueue new.
	lastMessageSentTime := nil.
	lastMessageReceivedTime := nil.
	lastBlockReceivedTime := nil.
	unfulfilledOutgoingRequests := OrderedCollection new.
	peerLock := Monitor new.
]

{ #category : #'initialize-release' }
BtRemotePeer >> initializeProcesses [
	self initializeSending .
	self initializeReceiving .
	self updateProcessesNames .
]

{ #category : #'initialize-release' }
BtRemotePeer >> initializeReceiving [
	receiving ifNotNil: [ receiving terminate ].
	receiving := BtExecutableBlock new
		block: [ 
			[ 
			self receiveAndEnqueueNextMessage.
			Processor yield ] repeat ]
]

{ #category : #'initialize-release' }
BtRemotePeer >> initializeSending [
	sending ifNotNil: [ sending terminate ].
	sending := BtExecutableBlock new
		block: [ 
			[ 
			self dequeueAndSendNextMessage.
			Processor yield ] repeat ]
]

{ #category : #accessing }
BtRemotePeer >> isAccepted [
	^peerLock critical: [ isAccepted ]
]

{ #category : #accessing }
BtRemotePeer >> isAccepted: anObject [
	peerLock critical: [ isAccepted := anObject ]
]

{ #category : #testing }
BtRemotePeer >> isConnected [
	^peerLock critical: [
		socketStream 
			ifNil: [ false ]
			ifNotNil: [ socketStream isConnected ]  
	] 
]

{ #category : #accessing }
BtRemotePeer >> isInterested [
	^peerLock critical: [ isInterested ]
]

{ #category : #accessing }
BtRemotePeer >> isInterested: anObject [
	peerLock critical: [ isInterested := anObject ]
]

{ #category : #accessing }
BtRemotePeer >> isInteresting [
	^peerLock critical: [ isInteresting ]
]

{ #category : #accessing }
BtRemotePeer >> isInteresting: anObject [
	peerLock critical: [ isInteresting := anObject ]
]

{ #category : #accessing }
BtRemotePeer >> isLucky [
	^ peerLock critical: [ isLucky ]
]

{ #category : #accessing }
BtRemotePeer >> isLucky: anObject [
	peerLock critical: [isLucky := anObject]
]

{ #category : #accessing }
BtRemotePeer >> isSnubber [
	^ self secondsSinceLastReceivedBlock > (BtTorrent maxTimeWithoutReceivedBlocks)
]

{ #category : #operations }
BtRemotePeer >> notAccept [
	self
		sendChoke;
		discardOutgoingBlocks;
		discardUnfulfilledIncomingRequests;
		isAccepted: false
]

{ #category : #accessing }
BtRemotePeer >> port: anInteger [
	super port: anInteger .
	self updateProcessesNames.
]

{ #category : #printing }
BtRemotePeer >> printOn: aStream [
	aStream
		nextPutAll: 'Remote peer[';
		nextPutAll: domain address asIPv4 dotted;
		nextPutAll: ':';
		nextPutAll: port asString;
		nextPutAll: ']'
]

{ #category : #queues }
BtRemotePeer >> receiveAndEnqueueNextMessage [
	| messageReceived |
	messageReceived := [ self receiveNextMessage ]
		on: ConnectionTimedOut , BtMessageError
		do: [ :ex | ex return: nil ].
	messageReceived ifNotNil: [ inMessageQueue nextPut: messageReceived ]
]

{ #category : #'messages-receive' }
BtRemotePeer >> receiveHandshake [
	| stream |
	stream := WriteStream with: (self receiveNext: 68).
	^ stream contents decodeHandshake
]

{ #category : #'messages-receive' }
BtRemotePeer >> receiveIntegerOfSize: size [
	^ (self receiveNext: size) asInteger
]

{ #category : #'messages-receive' }
BtRemotePeer >> receiveNext: amount [
	| bytes |
	bytes:=socketStream next: amount.
	bytes size ~= amount 
		ifTrue:[BtMessageError signal]
		ifFalse:[^ bytes]
]

{ #category : #'messages-receive' }
BtRemotePeer >> receiveNextMessage [
	| length stream prefix |
	prefix := self receiveNext: 4.
	stream := WriteStream with: prefix.
	length := prefix asInteger.
	length > 0
		ifTrue: [ stream nextPutAll: (self receiveNext: length) ].
	^ stream contents decodeMessage
]

{ #category : #operations }
BtRemotePeer >> request: aBlockRequest [
	peerLock
		critical: [ 
			self sendRequest: aBlockRequest pieceIndex begin: aBlockRequest offset length: aBlockRequest length.
			(unfulfilledOutgoingRequests includes: aBlockRequest)
				ifFalse: [ unfulfilledOutgoingRequests add: aBlockRequest ] ]
]

{ #category : #operations }
BtRemotePeer >> restartMeasuringRates [
	peerLock
		critical: [ 
			startMeasuringTime := Time millisecondClockValue.
			lastUploaded amount: uploaded amount.
			lastDownloaded amount: downloaded amount]
]

{ #category : #operations }
BtRemotePeer >> resume [
	receiving resume .
	sending resume .
]

{ #category : #operations }
BtRemotePeer >> secondsSinceLastReceivedBlock [
	^peerLock critical: [  
		lastBlockReceivedTime ifNil: [ lastBlockReceivedTime := Time millisecondClockValue  ].
		(Time millisecondsSince: lastBlockReceivedTime) / 1000	
	]
]

{ #category : #operations }
BtRemotePeer >> secondsSinceLastReceivedMessage [
	^ peerLock
		critical: [ 
			lastMessageReceivedTime ifNil: [ lastMessageReceivedTime := Time millisecondClockValue ].
			(Time millisecondsSince: lastMessageReceivedTime) / 1000 ]
]

{ #category : #operations }
BtRemotePeer >> secondsSinceLastSentMessage [
	^ peerLock
		critical: [ 
			lastMessageSentTime ifNil: [ lastMessageSentTime := Time millisecondClockValue ].
			(Time millisecondsSince: lastMessageSentTime) / 1000 ]
]

{ #category : #'messages-send' }
BtRemotePeer >> sendBitfield:  aBitfield [ 
	self enqueue: (BtMessage bitfieldMessage: aBitfield ).
	self log: aBitfield asString , ' sent'
]

{ #category : #'messages-send' }
BtRemotePeer >> sendCancel: index begin: begin length: length [
	| payload message |
	message := BtMessage cancelMessage: index begin: begin length: length.
	self enqueue: message.
	payload := message payload.
	self log: 'CANCEL: ' , payload asString , ' sent'.
]

{ #category : #'messages-send' }
BtRemotePeer >> sendChoke [
	self enqueue: BtMessage chokeMessage.
	self log: 'CHOKE sent'.
]

{ #category : #'messages-send' }
BtRemotePeer >> sendHandshake: infoHash id: localPeerId [
	socketStream nextPutAllFlush: (BtHandshakeMessage infoHash: infoHash id: localPeerId ) asByteArray 
	
]

{ #category : #'messages-send' }
BtRemotePeer >> sendHave: pieceIndex [
	self enqueue: (BtMessage haveMessage: pieceIndex) .
	self log: 'HAVE: ' , pieceIndex asString , ' sent'
]

{ #category : #'messages-send' }
BtRemotePeer >> sendInterested [
	self enqueue: BtMessage interestedMessage.
	self log: 'INTERESTED sent'
]

{ #category : #'messages-send' }
BtRemotePeer >> sendKeepAlive [
	self enqueue: BtMessage keepAliveMessage .
	self log: 'KEEP-ALIVE sent'
]

{ #category : #'messages-send' }
BtRemotePeer >> sendNotInterested [
	self enqueue: BtMessage notInterestedMessage.
	self log: 'NOT INTERESTED sent'
]

{ #category : #'messages-send' }
BtRemotePeer >> sendPiece: index begin: begin block: block [
	|  message |
	message := BtMessage pieceMessage: index begin: begin block: block.
	self enqueue: message.
	self log: 'PIECE: ' , message payload asString , ' sent'.
]

{ #category : #'messages-send' }
BtRemotePeer >> sendPort:  aPort [
	self enqueue: (BtMessage portMessage: aPort ).
	self log: 'PORT: ' , aPort asString , ' sent'
]

{ #category : #'messages-send' }
BtRemotePeer >> sendRequest: index begin: begin length: length [
	| message  |
	message := BtMessage requestMessage: index begin: begin length: length.
	self enqueue: message.
	self log: 'REQUEST: ' , message payload asString , ' sent'
]

{ #category : #'messages-send' }
BtRemotePeer >> sendUnchoke [
	self enqueue: BtMessage unchokeMessage.
	self log: 'UNCHOKE sent'
]

{ #category : #operations }
BtRemotePeer >> setInteresting [
	self
		sendInterested;
		isInteresting: true
]

{ #category : #operations }
BtRemotePeer >> setNotInteresting [
	self
		sendNotInterested;
		isInteresting: false
]

{ #category : #'piece control' }
BtRemotePeer >> setPieceAt: index [
	^ peerLock critical: [ bitfield set: index ]
]

{ #category : #operations }
BtRemotePeer >> setTimeOut [
	peerLock critical: [ socketStream ifNotNil: [ socketStream timeout: BtMessage connectionTimeOut ] ]
]

{ #category : #accessing }
BtRemotePeer >> socketStream [
	^peerLock critical: [ socketStream ]
]

{ #category : #accessing }
BtRemotePeer >> socketStream: anObject [
	peerLock critical: [ 
		socketStream := anObject.
		socketStream binary .
		socketStream timeout: BtMessage connectionTimeOut .
	]
]

{ #category : #operations }
BtRemotePeer >> terminate [
	receiving terminate.
	sending terminate .
]

{ #category : #accessing }
BtRemotePeer >> unfulfilledIncomingRequests [
	^ peerLock
		critical: [ 
			inMessageQueue selectRequests
				collect: [ :request | 
					| payload |
					payload := request payload.
					BtBlockRequest pieceIndex: payload index offset: payload begin length: payload length ] ]
]

{ #category : #accessing }
BtRemotePeer >> unfulfilledOutgoingRequests [
	^peerLock critical: [ unfulfilledOutgoingRequests ]
]

{ #category : #operations }
BtRemotePeer >> unfulfilledOutgoingRequestsAt: pieceIndex [
	^peerLock critical: [ unfulfilledOutgoingRequests select:[:blockRequest| blockRequest pieceIndex = pieceIndex ]  ]
]

{ #category : #operations }
BtRemotePeer >> updateInterest: localBitfield [
	peerLock
		critical: [ 
			| interestingBitfield |
			interestingBitfield := localBitfield interestingBitfield: bitfield.
			interestingBitfield numBitsSet > 0
				ifTrue: [ 
					isInteresting
						ifFalse: [ self setInteresting ] ]
				ifFalse: [ 
					isInteresting
						ifTrue: [ self setNotInteresting ] ] ]
]

{ #category : #operations }
BtRemotePeer >> updateLastBlockReceivedTime [
	peerLock critical: [ lastBlockReceivedTime := Time millisecondClockValue ]
]

{ #category : #operations }
BtRemotePeer >> updateLastMessageReceivedTime [
	peerLock critical: [ lastMessageReceivedTime := Time millisecondClockValue ]
]

{ #category : #'initialize-release' }
BtRemotePeer >> updateProcessesNames [
	receiving name: self asString , ' Receiving'.
	sending name: self asString , ' Sending'.
]

{ #category : #'measuring rates' }
BtRemotePeer >> uploadRate [
	^ peerLock
		critical: [ 
			| display |
			display := BtByteRateDisplay new.
			display byteDisplay
				amount:
					([ (uploaded amount - lastUploaded amount) / (Time millisecondsSince: startMeasuringTime) ]
						on: ZeroDivide
						do: [ :ex | ex return: 0 ]).
			display ]
]

{ #category : #accessing }
BtRemotePeer >> uploaded [
	^peerLock critical: [ uploaded ]
]

{ #category : #accessing }
BtRemotePeer >> uploaded: anObject [
	peerLock critical: [ uploaded := anObject ].
]
