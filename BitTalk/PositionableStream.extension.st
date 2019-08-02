Extension { #name : #PositionableStream }

{ #category : #'*BitTalk' }
PositionableStream >> bedecodeAssociation [
	self peek asCharacter isDigit
		ifFalse: [ self error: 'Key must be a bencoded string' ].
	^ self bedecodeString -> self bedecoded
]

{ #category : #'*BitTalk' }
PositionableStream >> bedecodeDictionary [
	| dictionary |
	dictionary := Dictionary new.
	self next.
	[ self peek asCharacter ~= $e ] whileTrue: [ dictionary add: self bedecodeAssociation ].
	self next.
	^ dictionary
]

{ #category : #'*BitTalk' }
PositionableStream >> bedecodeInteger [
	self next.
	^(self upTo: $e asInteger) asString asInteger 
]

{ #category : #'*BitTalk' }
PositionableStream >> bedecodeList [
	| list |
	self next.
	list := OrderedCollection new.
	[ self peek asCharacter ~= $e ] whileTrue: [ list add: self bedecoded ].
	self next.
	^ list
]

{ #category : #'*BitTalk' }
PositionableStream >> bedecodeString [
	| length |
	length := ((self upTo: $: asInteger) asString trimRight: [ :x | x isDigit not ]) asInteger.
	^ (self next: length) asString
]

{ #category : #'*BitTalk' }
PositionableStream >> bedecoded [
	| elem |
	elem := self peek asCharacter.
	^ elem = $i
		ifTrue: [ self bedecodeInteger ]
		ifFalse: [ 
			elem isDigit
				ifTrue: [ self bedecodeString ]
				ifFalse: [ 
					elem = $l
						ifTrue: [ self bedecodeList ]
						ifFalse: [ 
							elem = $d
								ifTrue: [ self bedecodeDictionary ]
								ifFalse: [ self error: 'Unknown bencoded form' ] ] ] ]
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeBitfieldPayload: length [
	^ BtBitfieldPayload new bitfield: (BtBitfield new: length * 8 with: (self next: length))
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeBlockDescriptionPayload [
	^ BtBlockDescriptionPayload new
		index: (self decodeIntegerOfSize: 4);
		begin: (self decodeIntegerOfSize: 4);
		length: (self decodeIntegerOfSize: 4)
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeBlockOfLength: length [
	^ self next: length
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeBlockPayload: length [
	^ BtBlockPayload new
		index: (self decodeIntegerOfSize: 4);
		begin: (self decodeIntegerOfSize: 4);
		block: (self decodeBlockOfLength: length - 8)
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeHandshake [
	| handshake length |
	handshake := BtHandshakeMessage new.
	length := self decodeProtocolIdentifierLength.
	^handshake
		protocolIdentifier: (self decodeProtocolIdentifier: length);
		protocolBehaviour: self decodeProtocolBehaviour;
		infoHash: self decodeInfoHash;
		peerID: self decodePeerID.
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeHavePayload [
	^ BtHavePayload new index: (self decodeIntegerOfSize: 4)
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeInfoHash [
	^ self decodeIntegerOfSize: 20
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeIntegerOfSize: size [
	^(self next: size) asInteger
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeLength [
	^ self decodeIntegerOfSize: 4
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeMessage [
	| message length |
	message:= BtMessage new.
	length:=self decodeLength.
	length > 0
		ifTrue:[
			message type: self decodeType.
			length > 1
				ifTrue:[message payload: (self decodePayload: message type length: length - 1)]
		].
	^message
]

{ #category : #'*BitTalk' }
PositionableStream >> decodePayload: type length: length [
	^ type = BtMessage haveMessageType
		ifTrue: [ self decodeHavePayload ]
		ifFalse: [ 
			type = BtMessage bitfieldMessageType
				ifTrue: [ self decodeBitfieldPayload: length ]
				ifFalse: [ 
					| blockDescriptionPayloadCodes |
					blockDescriptionPayloadCodes := OrderedCollection
						with: BtMessage requestMessageType
						with: BtMessage cancelMessageType.
					(blockDescriptionPayloadCodes includes: type)
						ifTrue: [ self decodeBlockDescriptionPayload ]
						ifFalse: [ 
							type = BtMessage pieceMessageType
								ifTrue: [ self decodeBlockPayload: length ]
								ifFalse: [ 
									type = BtMessage portMessageType
										ifTrue: [ self decodePortPayload ] ] ] ] ]
]

{ #category : #'*BitTalk' }
PositionableStream >> decodePeerID [
	^ self decodeIntegerOfSize: 20
]

{ #category : #'*BitTalk' }
PositionableStream >> decodePortPayload [
	^ BtPortPayload new port: (self decodeIntegerOfSize: 2)
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeProtocolBehaviour [
	^ BtProtocolBehaviour from: (self next: 8)
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeProtocolIdentifier: length [
	^ (self next: length) asString
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeProtocolIdentifierLength [
	^ self decodeIntegerOfSize: 1
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeType [
	^ self decodeIntegerOfSize: 1
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeUDPAnnounceResponse [
	|  packet |
	packet:=BtUDPAnnounceResponse new.
	packet 
		transaction: self decodeUDPTransaction ;
		interval: (self decodeIntegerOfSize: 4) ;
		leechers: (self decodeIntegerOfSize: 4) ;
		seeders: (self decodeIntegerOfSize: 4) .
	[self atEnd] 
		whileFalse: [
			|node domain|
			node:= BtNode new.
			domain:=BtDomain new address: (self decodeIntegerOfSize: 4).
			node domain: domain.
			node port: (self decodeIntegerOfSize: 2).	
			packet nodeCollection add: node.	
		].	
	 ^packet
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeUDPConnectResponse [
	|  packet |
	packet:=BtUDPConnectResponse new.
	packet 
		transaction: self decodeUDPTransaction ;
		connectionID: (self decodeIntegerOfSize: 8).
	 ^packet
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeUDPErrorResponse [
	|  packet |
	packet:=BtUDPErrorResponse new.
	packet 
		transaction: self decodeUDPTransaction ;
		message: self upToEnd asString .
	 ^packet
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeUDPResponse [
	| actionCode |
	self size < 4
		ifTrue:[BtWrongPacketSize signal].
	actionCode:= (self next: 4) asInteger.
	(BtUDPTransaction actionCodes includes: actionCode)
		ifFalse: [ BtWrongActionCode signal: 'actionCode has to be any of ', (BtUDPTransaction actionCodes asString) ].		
	4 timesRepeat: [ self back ].
	actionCode = (BtUDPTransaction announceActionCode)
		ifTrue:[^self decodeUDPAnnounceResponse].
	actionCode = (BtUDPTransaction connectActionCode)
		ifTrue:[^self decodeUDPConnectResponse].	
	actionCode = (BtUDPTransaction scrapeActionCode)
		ifTrue:[^self decodeUDPScrapeResponse].
	actionCode = (BtUDPTransaction errorActionCode)
		ifTrue:[^self decodeUDPErrorResponse].
	
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeUDPScrapeResponse [
	|  packet |
	packet:=BtUDPScrapeResponse new.
	packet transaction: self decodeUDPTransaction .

	[self atEnd] 
		whileFalse: [ packet scrapeTorrentStatCollection add: (self decodeUDPScrapeTorrentStat )].	
	 ^packet
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeUDPScrapeTorrentStat [
	| scrapeTorrentStat  |
	scrapeTorrentStat:=BtUDPScrapeTorrentStat new.
	scrapeTorrentStat
		seeders: (self decodeIntegerOfSize: 4) ;
		completed: (self decodeIntegerOfSize: 4) ;
		leechers: (self decodeIntegerOfSize: 4) .
	^scrapeTorrentStat 
]

{ #category : #'*BitTalk' }
PositionableStream >> decodeUDPTransaction [
	| transaction |
	transaction:=BtUDPTransaction new.
	transaction actionCode: (self decodeIntegerOfSize: 4).
	transaction id: (self decodeIntegerOfSize: 4).
	^transaction
]
