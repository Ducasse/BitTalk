"
A BtKRPC is xxxxxxxxx.

"
Class {
	#name : #BtRPC,
	#superclass : #Dictionary,
	#classVars : [
		'ArgumentKey',
		'ErrorKey',
		'ErrorValue',
		'GenericErrorCode',
		'IdKey',
		'MethodUnknownErrorCode',
		'ProtocolErrorCode',
		'QueryKey',
		'QueryValue',
		'ResponseKey',
		'ResponseValue',
		'ServerErrorCode',
		'TransactionKey',
		'TypeKey'
	],
	#category : #'BitTalk-DHT'
}

{ #category : #accessing }
BtRPC class >> argumentKey [
	^ ArgumentKey
]

{ #category : #'instance creation' }
BtRPC class >> from: aDictionary [
	| krpc |
	krpc := self new.
	aDictionary associationsDo: [ :association | krpc add: association ].
	^ krpc
]

{ #category : #operations }
BtRPC class >> generateTransactionID [
	^ (2 raisedTo: 16) atRandom - 1
]

{ #category : #accessing }
BtRPC class >> idKey [
	^ IdKey 
]

{ #category : #'initialize-release' }
BtRPC class >> initialize [
	super initialize.
	GenericErrorCode := 201.
	ServerErrorCode := 202.
	ProtocolErrorCode := 203.
	MethodUnknownErrorCode := 204.
	TransactionKey := 't'.
	TypeKey := 'y'.
	QueryValue := 'q'.
	ResponseValue := 'r'.
	ErrorValue := 'e'.
	QueryKey := 'q'.
	ResponseKey := 'r'.
	ErrorKey := 'e'.
	ArgumentKey := 'a'.
	IdKey := 'id'
]

{ #category : #'instance creation' }
BtRPC class >> new [
	^ super new initialize
]

{ #category : #'instance creation - queries' }
BtRPC class >> newAnnouncePeerQuery: anIntegerTransactionID queryingNodeID: anIntegerQueryingNodeID impliedPort: anIntegerImpliedPort infohash: anIntegerInfohash port: anIntegerPort token: anIntegerToken [
	| arguments |
	arguments := Dictionary new.
	arguments
		at: IdKey put: (anIntegerQueryingNodeID asByteArrayOfSize: 20) asString;
		at: 'implied_port' put: anIntegerImpliedPort;
		at: 'info_hash' put: (anIntegerInfohash asByteArrayOfSize: 20) asString;
		at: 'port' put: anIntegerPort;
		at: 'token' put: (anIntegerToken asByteArrayOfSize: 8) asString.
	^ self newQuery: anIntegerTransactionID methodName: 'announce_peer' arguments: arguments
]

{ #category : #'instance creation - responses' }
BtRPC class >> newAnnouncePeerResponse: anIntegerTransactionID queriedNodeID: anInteger [
	| arguments |
	arguments := Dictionary new.
	arguments at: IdKey put: (anInteger asByteArrayOfSize: 20) asString. 
	^ self newResponse: anIntegerTransactionID return: arguments 
]

{ #category : #'private - instance creation' }
BtRPC class >> newError: anIntegerTransactionID value: anOrderedCollection [
	| krpc |
	krpc := self newMessage: anIntegerTransactionID.
	^ krpc
		at: TypeKey put: ErrorValue ;
		at: ErrorKey put: anOrderedCollection;
		yourself
]

{ #category : #'instance creation - queries' }
BtRPC class >> newFindNodeQuery: anIntegerTransactionID queryingNodeID: anIntegerQueryingNodeID target: anIntegerTarget [
	| arguments |
	arguments := Dictionary new.
	arguments
		at: IdKey put: (anIntegerQueryingNodeID asByteArrayOfSize: 20) asString;
		at: 'target' put: (anIntegerQueryingNodeID asByteArrayOfSize: 20) asString.
	^ self newQuery: anIntegerTransactionID methodName: 'find_node' arguments: arguments
]

{ #category : #'instance creation - responses' }
BtRPC class >> newFindNodeResponse: anIntegerTransactionID queriedNodeID: anInteger nodes: aString [
	| arguments |
	arguments := Dictionary new.
	arguments
		at: IdKey put: (anInteger asByteArrayOfSize: 20) asString;
		at: 'nodes' put: aString.
	^ self newResponse: anIntegerTransactionID return: arguments
]

{ #category : #'instance creation - errors' }
BtRPC class >> newGenericError: anIntegerTransactionID message: aString [
	| collection |
	collection := OrderedCollection with: GenericErrorCode with: aString.
	^ self newError: anIntegerTransactionID value: collection 
]

{ #category : #'instance creation - queries' }
BtRPC class >> newGetPeersQuery: anIntegerTransactionID queryingNodeID: anIntegerQueryingNodeID infohash: anIntegerInfohash [
	| arguments |
	arguments := Dictionary new.
	arguments
		at: IdKey put: (anIntegerQueryingNodeID asByteArrayOfSize: 20) asString;
		at: 'info_hash' put: (anIntegerInfohash asByteArrayOfSize: 20) asString.
	^ self newQuery: anIntegerTransactionID methodName: 'geet_peers' arguments: arguments
]

{ #category : #'instance creation - responses' }
BtRPC class >> newGetPeersResponse: anIntegerTransactionID queriedNodeID: anIntegerQueriedNodeID token: anIntegerToken nodes: aString [
	| arguments |
	arguments := Dictionary new.
	arguments
		at: IdKey put: (anIntegerQueriedNodeID asByteArrayOfSize: 20) asString;
		at: 'token' put: (anIntegerToken asByteArrayOfSize: 8) asString;
		at: 'values' put: aString.
	^ self newResponse: anIntegerTransactionID return: arguments
]

{ #category : #'instance creation - responses' }
BtRPC class >> newGetPeersResponse: anIntegerTransactionID queriedNodeID: anIntegerQueriedNodeID token: anIntegerToken values: anOrderedCollection [
	| arguments |
	arguments := Dictionary new.
	arguments
		at: IdKey put: (anIntegerQueriedNodeID asByteArrayOfSize: 20) asString;
		at: 'token' put: (anIntegerToken asByteArrayOfSize: 8) asString;
		at: 'values' put: anOrderedCollection.
	^ self newResponse: anIntegerTransactionID return: arguments
]

{ #category : #'private - instance creation' }
BtRPC class >> newMessage: anIntegerTransactionID [
	| krpc |
	krpc := self new.
	^ krpc
		at: TransactionKey put: (anIntegerTransactionID asByteArrayOfSize: 2) asString;
		at: TypeKey put: nil;
		yourself
]

{ #category : #'instance creation - errors' }
BtRPC class >> newMethodUnknownError: anIntegerTransactionID message: aString [
	| collection |
	collection := OrderedCollection with: MethodUnknownErrorCode with: aString.
	^ self newError: anIntegerTransactionID value: collection
]

{ #category : #'instance creation - queries' }
BtRPC class >> newPingQuery: anIntegerTransactionID queryingNodeID: anInteger [
	|  arguments |
	arguments:= Dictionary new.
	arguments at: IdKey put: (anInteger asByteArrayOfSize: 20) asString.
	^ self newQuery: anIntegerTransactionID methodName: 'ping' arguments: arguments. 
]

{ #category : #'instance creation - responses' }
BtRPC class >> newPingResponse: anIntegerTransactionID queriedNodeID: anInteger [
	| arguments |
	arguments := Dictionary new.
	arguments at: IdKey put: (anInteger asByteArrayOfSize: 20) asString. 
	^ self newResponse: anIntegerTransactionID return: arguments 
]

{ #category : #'instance creation - errors' }
BtRPC class >> newProtocolError: anIntegerTransactionID message: aString [
	| collection |
	collection := OrderedCollection with: ProtocolErrorCode with: aString.
	^ self newError: anIntegerTransactionID value: collection
]

{ #category : #'private - instance creation' }
BtRPC class >> newQuery: anIntegerTransactionID methodName: aString arguments: aDictionary [
	| krpc |
	krpc := self newMessage: anIntegerTransactionID.
	^ krpc
		at: TypeKey put: QueryValue ;
		at: QueryKey put: aString;
		at: ArgumentKey put: aDictionary;
		yourself
]

{ #category : #'private - instance creation' }
BtRPC class >> newResponse: anIntegerTransactionID return: aDictionary [
	| krpc |
	krpc := self newMessage: anIntegerTransactionID.
	^ krpc
		at: TypeKey put: ResponseValue ;
		at: ResponseKey put: aDictionary;
		yourself
]

{ #category : #'instance creation - errors' }
BtRPC class >> newServerError: anIntegerTransactionID message: aString [
	| collection |
	collection := OrderedCollection with: ServerErrorCode with: aString.
	^ self newError: anIntegerTransactionID value: collection
]

{ #category : #accessing }
BtRPC class >> responseKey [
	^ ResponseKey
]

{ #category : #testing }
BtRPC >> isError [
	^ (self at: TypeKey) = ErrorValue
]

{ #category : #testing }
BtRPC >> isQuery [
	^ (self at: TypeKey) = QueryValue
]

{ #category : #testing }
BtRPC >> isResponse [
	^ (self at: TypeKey) = ResponseValue
]
