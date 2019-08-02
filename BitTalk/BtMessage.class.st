"
A BtP2PMessage is xxxxxxxxx.

"
Class {
	#name : #BtMessage,
	#superclass : #Object,
	#instVars : [
		'payload',
		'type'
	],
	#classVars : [
		'BitfieldMessageCode',
		'CancelMessageCode',
		'ChokeMessageCode',
		'ConnectionTimeOut',
		'HaveMessageCode',
		'InterestedMessageCode',
		'NotInterestedMessageCode',
		'PieceMessageCode',
		'PortMessageCode',
		'RequestMessageCode',
		'UnchokeMessageCode'
	],
	#category : #'BitTalk-P2P'
}

{ #category : #messages }
BtMessage class >> bitfieldMessage: bitfield [ 
	|  codedMessage |	
	codedMessage := self new.
	codedMessage
		type: BitfieldMessageCode;
		payload: (BtBitfieldPayload new bitfield: bitfield).
	^codedMessage
]

{ #category : #accessing }
BtMessage class >> bitfieldMessageType [
	^ BitfieldMessageCode
]

{ #category : #messages }
BtMessage class >> cancelMessage: index begin: begin length: length [
	| codedMessage |	
	codedMessage := self new.
	codedMessage
		type: CancelMessageCode;
		payload: (BtBlockDescriptionPayload new index: index; begin: begin; length: length ).
	^codedMessage
]

{ #category : #accessing }
BtMessage class >> cancelMessageType [
	^ CancelMessageCode
]

{ #category : #messages }
BtMessage class >> chokeMessage [
	| codedMessage |	
	codedMessage := self new.
	codedMessage type: ChokeMessageCode.
	^codedMessage
]

{ #category : #accessing }
BtMessage class >> chokeMessageType [
	^ ChokeMessageCode
]

{ #category : #accessing }
BtMessage class >> chokingMessagesTypes [
	^ { ChokeMessageCode . UnchokeMessageCode }
]

{ #category : #accessing }
BtMessage class >> connectionTimeOut [
	^ConnectionTimeOut 
]

{ #category : #messages }
BtMessage class >> haveMessage: index [
	| codedMessage |	
	codedMessage := self new.
	codedMessage
		type: HaveMessageCode;
		payload: (BtHavePayload new index: index).
	^codedMessage
]

{ #category : #accessing }
BtMessage class >> haveMessageType [
	^ HaveMessageCode
]

{ #category : #'initialize-release' }
BtMessage class >> initialize [
	super initialize.
	ChokeMessageCode := 0.
	UnchokeMessageCode := 1.
	InterestedMessageCode := 2.
	NotInterestedMessageCode := 3.
	HaveMessageCode := 4.
	BitfieldMessageCode := 5.
	RequestMessageCode := 6.
	PieceMessageCode := 7.
	CancelMessageCode := 8.
	PortMessageCode := 9.
	ConnectionTimeOut := 120.
]

{ #category : #accessing }
BtMessage class >> interestMessagesTypes [
	^{InterestedMessageCode . NotInterestedMessageCode }
]

{ #category : #messages }
BtMessage class >> interestedMessage [
	| codedMessage |	
	codedMessage := self new.
	codedMessage type: InterestedMessageCode.
	^codedMessage
]

{ #category : #accessing }
BtMessage class >> interestedMessageType [
	^ InterestedMessageCode
]

{ #category : #messages }
BtMessage class >> keepAliveMessage [
	^self new
]

{ #category : #messages }
BtMessage class >> notInterestedMessage [
	| codedMessage |	
	codedMessage := self new.
	codedMessage type: NotInterestedMessageCode.
	^codedMessage
]

{ #category : #accessing }
BtMessage class >> notInterestedMessageType [
	^ NotInterestedMessageCode
]

{ #category : #messages }
BtMessage class >> pieceMessage: index begin: begin block: block [
	| codedMessage  |	
	codedMessage := self new.
	codedMessage
		type: PieceMessageCode;
		payload: (BtBlockPayload new index: index; begin: begin; block: block ).
	^codedMessage
]

{ #category : #accessing }
BtMessage class >> pieceMessageType [
	^ PieceMessageCode
]

{ #category : #messages }
BtMessage class >> portMessage: port [
	| codedMessage  |	
	codedMessage := self new.
	codedMessage
		type: PortMessageCode;
		payload: (BtPortPayload new port: port).
	^codedMessage
]

{ #category : #accessing }
BtMessage class >> portMessageType [
	^ PortMessageCode
]

{ #category : #messages }
BtMessage class >> requestMessage: index begin: begin length: length [
	| codedMessage |	
	codedMessage := self new.
	codedMessage
		type: RequestMessageCode;
		payload: (BtBlockDescriptionPayload new index: index; begin: begin; length: length ).
	^codedMessage
]

{ #category : #accessing }
BtMessage class >> requestMessageType [
	^ RequestMessageCode
]

{ #category : #messages }
BtMessage class >> unchokeMessage [
	| codedMessage |	
	codedMessage := self new.
	codedMessage type: UnchokeMessageCode.
	^codedMessage
]

{ #category : #accessing }
BtMessage class >> unchokeMessageType [
	^ UnchokeMessageCode
]

{ #category : #comparing }
BtMessage >> = anotherMessage [
	^ self == anotherMessage
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherMessage species
				ifTrue: [ type = (anotherMessage type) and:[payload = anotherMessage payload] ]
				ifFalse: [ false ] 
		]
]

{ #category : #'converting-arrays' }
BtMessage >> asByteArray [
	| bytesPayload length message |
	length := type ifNil: [ 0 ] ifNotNil: [ 1 ].
	bytesPayload := payload ifNil: [ ByteArray new ] ifNotNil: [ payload asByteArray ].
	length := length + bytesPayload size.
	message := OrderedCollection new.
	message addAll: (length asByteArrayOfSize: 4).
	type ifNotNil: [ message add: type ].
	message addAll: bytesPayload.
	^ message asByteArray
]

{ #category : #'initialize-release' }
BtMessage >> initialize [
	super initialize.
	type:= nil.
	payload:= nil.
	
]

{ #category : #accessing }
BtMessage >> payload [
	^ payload
]

{ #category : #accessing }
BtMessage >> payload: anObject [
	payload := anObject
]

{ #category : #accessing }
BtMessage >> type [
	^ type
]

{ #category : #accessing }
BtMessage >> type: anObject [
	type := anObject
]
