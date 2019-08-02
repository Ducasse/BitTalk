"
A BtDHT is xxxxxxxxx.

"
Class {
	#name : #BtDHTLocalNode,
	#superclass : #BtDHTNode,
	#instVars : [
		'bucketTree',
		'socket',
		'inQueue',
		'outQueue',
		'incomingTransactionIDs',
		'outgoingTransactionIDs',
		'receiving',
		'sending'
	],
	#classVars : [
		'DefaultMaxInactivityPeriod',
		'MaxInactivityPeriod'
	],
	#category : #'BitTalk-DHT'
}

{ #category : #operations }
BtDHTLocalNode class >> generateNodeID [
	^ (2 raisedTo: 160) atRandom - 1
]

{ #category : #'initialize-release' }
BtDHTLocalNode class >> initialize [
	super initialize.
	DefaultMaxInactivityPeriod := 15*60*1000.
	MaxInactivityPeriod := DefaultMaxInactivityPeriod .
]

{ #category : #accessing }
BtDHTLocalNode class >> maxInactivityPeriod [
	^ MaxInactivityPeriod 
]

{ #category : #'private - accessing' }
BtDHTLocalNode class >> maxInactivityPeriod: anInteger [
	MaxInactivityPeriod := anInteger
]

{ #category : #accessing }
BtDHTLocalNode class >> setDefaultMaxInactivityPeriod [
	MaxInactivityPeriod := DefaultMaxInactivityPeriod 
]

{ #category : #queries }
BtDHTLocalNode >> announcePeerQueryTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID impliedPort: anIntegerImpliedPort infohash: anIntegerInfohash port: anIntegerPort token: anIntegerToken [
	| rpc |
	rpc := BtRPC newAnnouncePeerQuery: anIntegerTransactionID queryingNodeID: id impliedPort: anIntegerImpliedPort infohash: anIntegerInfohash port: anIntegerPort token: anIntegerToken.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #responses }
BtDHTLocalNode >> announcePeerResponseTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID [
	| rpc |
	rpc := BtRPC newAnnouncePeerResponse: anIntegerTransactionID queriedNodeID: id.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #accessing }
BtDHTLocalNode >> domain: anObject [
	super domain: anObject.
	self updateProcessesNames .
]

{ #category : #queries }
BtDHTLocalNode >> findNodeQueryTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID target: anIntegerTargetID [
	| rpc |
	rpc := BtRPC newFindNodeQuery: anIntegerTransactionID queryingNodeID: id target: anIntegerTargetID . 
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #responses }
BtDHTLocalNode >> findNodeResponseTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID nodes: aStringNodes [
	| rpc |
	rpc := BtRPC newFindNodeResponse: anIntegerTransactionID queriedNodeID: id nodes: aStringNodes.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #errors }
BtDHTLocalNode >> genericErrorTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID message: aString [
	| rpc |
	rpc := BtRPC newGenericError: anIntegerTransactionID message: aString.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #queries }
BtDHTLocalNode >> getPeersQueryTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID swarm: anIntegerInfohash [
	| rpc |
	rpc := BtRPC newGetPeersQuery: anIntegerTransactionID queryingNodeID: id infohash: anIntegerInfohash.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #responses }
BtDHTLocalNode >> getPeersResponseTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID token: anIntegerToken nodes: aStringNodes [
	| rpc |
	rpc := BtRPC
		newGetPeersResponse: anIntegerTransactionID
		queriedNodeID: id
		token: anIntegerToken
		nodes: aStringNodes.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #responses }
BtDHTLocalNode >> getPeersResponseTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID token: anIntegerToken values: anOrderedCollectionValues [
	| rpc |
	rpc := BtRPC
		newGetPeersResponse: anIntegerTransactionID
		queriedNodeID: id
		token: anIntegerToken
		values: anOrderedCollectionValues.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #operations }
BtDHTLocalNode >> handleRPCAndNode: anArray [
"Eliminar transactionID en uso"
	| rpc node |
	rpc:= anArray first.
	node:= anArray second.
]

{ #category : #accessing }
BtDHTLocalNode >> id: anIntegerID [
	super id: anIntegerID .
	self updateProcessesNames .
]

{ #category : #'initialize-release' }
BtDHTLocalNode >> initialize [
	super initialize.
	socket := Socket newUDP.
	socket setPort: port.
	incomingTransactionIDs := OrderedCollection new.
	outgoingTransactionIDs := OrderedCollection new.
	inQueue := SharedQueue new.
	outQueue := SharedQueue new.
	bucketTree := BtBucketTree new.
	self initializeProcesses
]

{ #category : #'initialize-release' }
BtDHTLocalNode >> initializeProcesses [
	self initializeReceiving .
	self initializeSending .
	self updateProcessesNames .
]

{ #category : #'initialize-release' }
BtDHTLocalNode >> initializeReceiving [
	receiving ifNotNil: [ receiving terminate ].
	receiving := BtExecutableBlock new
		block: [ 
			[ true ]
				whileTrue: [
					self receiveAndHandleNextRPC. 
					(Delay forSeconds: 1) wait.
					Processor yield ] ]
]

{ #category : #'initialize-release' }
BtDHTLocalNode >> initializeSending [
	sending ifNotNil: [ sending terminate ].
	sending := BtExecutableBlock new
		block: [ 
			[ true ]
				whileTrue: [
					self sendAllPendingRPCs . 
					(Delay forSeconds: 1) wait.
					Processor yield ] ]
]

{ #category : #errors }
BtDHTLocalNode >> methodUnknownErrorTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID message: aString [
	| rpc |
	rpc := BtRPC newMethodUnknownError: anIntegerTransactionID message: aString.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #queries }
BtDHTLocalNode >> pingQueryTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID [
	| rpc |
	rpc := BtRPC newPingQuery: anIntegerTransactionID queryingNodeID: id.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #responses }
BtDHTLocalNode >> pingResponseTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID [
	| rpc |
	rpc := BtRPC newPingResponse: anIntegerTransactionID queriedNodeID: id.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #accessing }
BtDHTLocalNode >> port: anIntegerPort [
	super port: anIntegerPort .
	socket setPort: port.
	self updateProcessesNames .
]

{ #category : #errors }
BtDHTLocalNode >> protocolErrorTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID message: aString [
	| rpc |
	rpc := BtRPC newProtocolError: anIntegerTransactionID message: aString.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #operations }
BtDHTLocalNode >> receiveAndHandleNextRPC [
	self handleRPCAndNode: self receiveNextRPCAndNode .
]

{ #category : #operations }
BtDHTLocalNode >> receiveNextRPC [
]

{ #category : #operations }
BtDHTLocalNode >> receiveNextRPCAndNode [
	| buffer result address remotePort rpc dhtRemoteNode |
	buffer := ByteArray new: 2000.
	result := nil.
	[ result first = 0 ] whileTrue: [ result := socket socket receiveUDPDataInto: buffer ].
	result fourth
		ifTrue: [ self error: 'Incomplete datagram' ].
	address := result second.
	remotePort := result third.
	rpc := BtRPC from: (buffer copyFrom: 1 to: result first) bedecoded.
	dhtRemoteNode := BtDHTRemoteNode address: address asInteger port: remotePort.
	rpc isQuery
		ifTrue: [ dhtRemoteNode id: ((rpc at: BtRPC argumentKey) at: BtRPC idKey) ]
		ifFalse: [ 
			rpc isResponse
				ifTrue: [ dhtRemoteNode id: ((rpc at: BtRPC responseKey) at: BtRPC idKey) ] ].
	^ {rpc.
	dhtRemoteNode}
]

{ #category : #processes }
BtDHTLocalNode >> resume [
	receiving resume.
	sending resume.
]

{ #category : #operations }
BtDHTLocalNode >> sendAllPendingRPCs [	
	| rpc |
	[outQueue isEmpty] 
		whileFalse:[self sendNextRPC ].
		 
	[(rpc:=outQueue nextOrNil ) isNil ] 
		whileFalse:[
			self send
		]
]

{ #category : #operations }
BtDHTLocalNode >> sendNextRPC [
	"Reservar transactionID"
	| rpc |
	rpc:=outQueue nextOrNil.
	rpc ifNotNil: [  ] 
]

{ #category : #operations }
BtDHTLocalNode >> sendRPC: aBtRPC to: aBtDHTRemoteNode [
	socket sendData: aBtRPC bencoded toHost: aBtDHTRemoteNode domain address asIPv4 port: aBtDHTRemoteNode port
]

{ #category : #errors }
BtDHTLocalNode >> serverErrorTo: aBtDHTRemoteNode transactionID: anIntegerTransactionID message: aString [
	| rpc |
	rpc := BtRPC newServerError: anIntegerTransactionID message: aString.
	self sendRPC: rpc to: aBtDHTRemoteNode
]

{ #category : #processes }
BtDHTLocalNode >> terminate [
	receiving terminate.
	sending terminate.
]

{ #category : #processes }
BtDHTLocalNode >> updateProcessesNames [
	receiving name: self asString , ' Receiving'.
	sending name: self asString , ' Sending'
]
