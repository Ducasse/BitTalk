"
Represento un torrent. Tengo un BtMetainfo, un BtBitfield y una colección de BtPiece's ordenadas según mi metainfo.

torrent:= BtTorrent new.
torrent metainfo: aBtMetainfo . 
torrent location: aFileReference . 

------------------------------------------------------------------------------------

torrent := BtTorrent new.
torrent metainfo: (BtMetainfo new pieceLength: 10; buildOn: aFileReference ; yourself ).
torrent location: aFileReference .	




"
Class {
	#name : #BtTorrent,
	#superclass : #Object,
	#instVars : [
		'metainfo',
		'bitfield',
		'location',
		'remotePeers',
		'temporaryPieces',
		'blockSize',
		'uploaded',
		'downloaded',
		'id',
		'port',
		'started',
		'multitracker',
		'alreadyComplete',
		'tracker',
		'checkingFinished',
		'maxPeersAccepted',
		'maxConnections',
		'stopPending',
		'debug',
		'choking',
		'optimisticChoking',
		'receiving',
		'starting',
		'stopping',
		'trackerRequesting',
		'torrentLock',
		'measuringRates',
		'downloadRate',
		'lastDownloaded',
		'lastUploaded',
		'uploadRate',
		'downloadRateAverage',
		'uploadRateAverage',
		'fileCollection',
		'numPiecesDuringMostCommonPolicy',
		'piecesOnNetwork',
		'downloadMode',
		'requesting',
		'initialChecking',
		'isInMultitrackerMode',
		'maxUnfulfilledOutgoingRequestsPerPeer',
		'isActive'
	],
	#classVars : [
		'DefaultBlockSize',
		'DefaultMaxConnections',
		'DefaultMaxPeersAccepted',
		'DefaultMaxRemotePeers',
		'DefaultMaxSecondsForStopping',
		'DefaultMaxUnchoked',
		'DefaultMaxUnfulfilledOutgoingRequestsPerPeer',
		'DefaultTrackerRequestPeriod',
		'MaxTimeWithoutReceivedBlocks',
		'SmartMode',
		'StoreLocation',
		'StreamingMode'
	],
	#category : #BitTalk
}

{ #category : #accessing }
BtTorrent class >> defaultBlockSize [
	^ DefaultBlockSize
]

{ #category : #accessing }
BtTorrent class >> defaultMaxConnections [
	^ DefaultMaxConnections
]

{ #category : #accessing }
BtTorrent class >> defaultMaxPeersAccepted [
	^ DefaultMaxPeersAccepted
]

{ #category : #accessing }
BtTorrent class >> defaultMaxRemotePeers [
	^ DefaultMaxRemotePeers
]

{ #category : #accessing }
BtTorrent class >> defaultMaxUnchoked [
	^ DefaultMaxUnchoked
]

{ #category : #'initialize-release' }
BtTorrent class >> initialize [
	super initialize .
	StoreLocation := 'storeLocation'.
	DefaultMaxConnections := 10.
	DefaultTrackerRequestPeriod := 60.
	DefaultMaxPeersAccepted := 4.
	DefaultBlockSize := 2 raisedTo: 14.
	DefaultMaxSecondsForStopping := 2.
	MaxTimeWithoutReceivedBlocks := 60.
	DefaultMaxUnfulfilledOutgoingRequestsPerPeer := 20.
	SmartMode := 1.
	StreamingMode := 2.
]

{ #category : #accessing }
BtTorrent class >> maxTimeWithoutReceivedBlocks [
	^ MaxTimeWithoutReceivedBlocks
]

{ #category : #'instance creation' }
BtTorrent class >> metainfo: metainfo location: fileRef [
	| torrent |
	torrent:=BtTorrent new
		metainfo: metainfo;
		location: fileRef;
		yourself.
	torrent supportMultitracker ifTrue:[ torrent setMultitrackerMode ].
	^ torrent
]

{ #category : #'instance creation' }
BtTorrent class >> metainfoFileString: aString1 locationString: aString2 [
	| metainfoFile location metainfo |
	metainfoFile := aString1 asFileReference.
	location := aString2 asFileReference.
	metainfo := BtMetainfo
		from:
			(metainfoFile
				readStreamDo: [ :x | 
					x
						binary;
						bedecoded ]).
	^ BtTorrent metainfo: metainfo location: location
]

{ #category : #comparing }
BtTorrent >> = anotherTorrent [
	^ self == anotherTorrent
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherTorrent species
				ifTrue: [ self hash = anotherTorrent hash ]
				ifFalse: [ false ] ]
]

{ #category : #P2P }
BtTorrent >> addRemotePeer: remotePeer [
	torrentLock
		critical: [ 
			(remotePeers includes: remotePeer)
				ifFalse: [ 
					remotePeers add: remotePeer.
					self isComplete
						ifTrue: [ self lazyBitfieldTo: remotePeer ]
						ifFalse: [ 
							bitfield numBitsSet > 0
								ifTrue: [ remotePeer sendBitfield: bitfield ] ] ]
				ifTrue: [ remotePeer terminate ; destroy ] ]
]

{ #category : #testing }
BtTorrent >> alreadyComplete [
	^ alreadyComplete
]

{ #category : #'peer discovery' }
BtTorrent >> announceHasFailed [
	self currentTracker isUDP
		ifTrue:[ self waitForUDPAnnounceResponse ]. 
	^self currentTracker announceHasFailed
]

{ #category : #'piece control' }
BtTorrent >> bitfield [
	^torrentLock critical: [ bitfield ]
]

{ #category : #'private - P2P - requesting' }
BtTorrent >> blocksForRequestingInSmartMode [
	^ self isUsingMostCommonPolicy
		ifTrue: [ self mostCommonPiecesOnNetwork ]
		ifFalse: [ self rarestPiecesOnNetwork ]
]

{ #category : #'private - P2P - requesting' }
BtTorrent >> blocksForRequestingInStreamingMode [
	^ self lowestPiecesOnNetworkGreaterThan: bitfield firstBitClear - 1
]

{ #category : #P2P }
BtTorrent >> broadcastCancel: index begin: begin length: length [
	torrentLock
		critical: [ 
			| owners blockRequest |
			blockRequest := BtBlockRequest pieceIndex: index offset: begin length: length.
			owners := remotePeers selectWhoIHaveRequested: blockRequest.
			owners doCancel: blockRequest ]
]

{ #category : #P2P }
BtTorrent >> broadcastHave: pieceIndex [
	torrentLock critical: [ remotePeers doHave: pieceIndex ].
	
]

{ #category : #'P2P - requesting' }
BtTorrent >> broadcastRequestMissingBlocks: indexCollection [
	torrentLock critical: [ indexCollection do: [ :pieceIndex | self broadcastRequestMissingBlocksAt: pieceIndex ] ]
]

{ #category : #'private - P2P - requesting' }
BtTorrent >> broadcastRequestMissingBlocksAt: pieceIndex [
	| pieceOwners |
	pieceOwners := remotePeers selectAcceptsMe selectPieceOwnersOf: pieceIndex.
	pieceOwners do: [ :owner | self requestMissingBlocksAt: pieceIndex to: owner ]
]

{ #category : #P2P }
BtTorrent >> checkHandshake: handshake [
	(handshake protocolIdentifier = BtHandshakeMessage protocolIdentifier and: [ handshake infoHash = self hash ])
		ifFalse: [ BtHandshakeError signal ]
]

{ #category : #'piece control' }
BtTorrent >> checkPieces [
	torrentLock
		critical: [ 
			bitfield clearAll.
			0 to: metainfo numPieces - 1 do: [ :index | 
				| piece |
				piece := fileCollection readOffset: index * metainfo pieceLength amount: (metainfo pieceLengthOf: index).
				piece
					ifNotNil: [ 
						(SHA1 hashStream: piece readStream) = (metainfo sha1Of: index) asByteArray
							ifTrue: [ bitfield set: index ] ] ] ]
]

{ #category : #'piece control' }
BtTorrent >> checkingFinished [
	^ checkingFinished
]

{ #category : #'piece control' }
BtTorrent >> checkingFinished: anObject [
	checkingFinished := anObject
]

{ #category : #P2P }
BtTorrent >> clearUnfulfilledOutgoingRequestsThatAreMissingOnNetwork [
	torrentLock
		critical: [ 
			| requestedTemporaryBlocksToClear |
			requestedTemporaryBlocksToClear := self requestedTemporaryBlocks difference: self unfulfilledOutgoingRequestsOnNetwork.
			requestedTemporaryBlocksToClear
				do: [ :requestedTemporaryBlock | (temporaryPieces at: requestedTemporaryBlock pieceIndex + 1) clearRequest: requestedTemporaryBlock offset ] ]
]

{ #category : #P2P }
BtTorrent >> connectTo: remotePeer [
	[ 
	remotePeer connect.
	remotePeer sendHandshake: self hash id: id.
	self checkHandshake: remotePeer receiveHandshake.
	remotePeer resume.
	self addRemotePeer: remotePeer.
	self log: remotePeer asString , ' added' ]
		on: ConnectionTimedOut , BtHandshakeError , BtMessageError
		do: [ :ex | 
			remotePeer
				terminate;
				destroy.
			self log: 'Error adding ' , remotePeer asString , ': ' , ex asString.
			ex return ]
]

{ #category : #'piece control' }
BtTorrent >> currentDownloadModeAsString [
	^ self isUsingSmartMode
		ifTrue: [ 'Smart' ]
		ifFalse: [ 
			self isUsingStreamingMode
				ifTrue: [ 'Streaming' ]
				ifFalse: [ '' ] ]
]

{ #category : #'piece control' }
BtTorrent >> currentPiecePolicyAsString [
	^ self isInEndGame
		ifTrue: [ 'End Game' ]
		ifFalse: [ 
			self isUsingStreamingMode
				ifTrue: [ 
					self isUsingLowestPolicy
						ifTrue: [ 'Lowest' ] ]
				ifFalse: [ 
					self isUsingSmartMode
						ifTrue: [ 
							self isUsingMostCommonPolicy
								ifTrue: [ 'Most common' ]
								ifFalse: [ 
									self isUsingRarestPolicy
										ifTrue: [ 'Rarest' ] ] ] ] ]
]

{ #category : #'peer discovery' }
BtTorrent >> currentTracker [
	^self isInMultitrackerMode
		ifTrue:[multitracker current ]
		ifFalse:[tracker].
]

{ #category : #accessing }
BtTorrent >> debug: aBoolean [
	debug := aBoolean.
	debug
		ifFalse: [ ^ self ].
	tracker debug: aBoolean.
	multitracker tierCollection do: [ :tier | tier do: [ :t | t debug: aBoolean ] ]
]

{ #category : #operations }
BtTorrent >> delete [
	torrentLock critical: [ self files do: [ :file | file ensureDelete ] ]
]

{ #category : #P2P }
BtTorrent >> discardAllRemotePeers [
	torrentLock critical: [ [ remotePeers isEmpty ] whileFalse: [ self discardRemotePeer: remotePeers first ] ]
]

{ #category : #P2P }
BtTorrent >> discardRemotePeer: remotePeer [
	torrentLock
		critical: [ 
			remotePeer
				terminate;
				destroy.
			remotePeer bitfield ifNotNil: [ remotePeer bitfield bitsSet do: [ :index | piecesOnNetwork modifyAt: index by: -1 ] ].
			remotePeers remove: remotePeer.
			self clearUnfulfilledOutgoingRequestsThatAreMissingOnNetwork ].
	self log: remotePeer asString , ' discarded'
]

{ #category : #P2P }
BtTorrent >> discardSeeders [
	torrentLock critical: [ remotePeers selectSeeders do: [ :peer | self discardRemotePeer: peer ] ]
]

{ #category : #'peer discovery' }
BtTorrent >> doAnnounce [
	self selectLastTracker.
	[ 
	self selectNextTracker.
	self updateAnnounceRequest.
	self currentTracker announce.
	Processor yield ] doWhileTrue: [ self announceHasFailed ].
	self lastAnnounceEventIsCompleted
		ifTrue: [ alreadyComplete := true ]
		ifFalse: [ started := true ].
	self moveCurrentTrackerToFirstInTier.
	self updateRemotePeers
]

{ #category : #'P2P - requesting' }
BtTorrent >> doRequesting [
	| halfwayNotFullRequestedPieces |
	halfwayNotFullRequestedPieces := self halfwayNotFullRequestedPieces difference: self missingPiecesOnNetwork.
	self isInEndGame
		ifTrue: [ self broadcastRequestMissingBlocks: halfwayNotFullRequestedPieces ]
		ifFalse: [ 
			self requestMissingAndNotRequestedBlocksOf: halfwayNotFullRequestedPieces.
			self isUsingStreamingMode
				ifTrue: [ 
					self
						requestMissingAndNotRequestedBlocksOf:
							(self blocksForRequestingInStreamingMode difference: halfwayNotFullRequestedPieces) ]
				ifFalse: [ 
					self
						requestMissingAndNotRequestedBlocksOf:
							(self blocksForRequestingInSmartMode difference: halfwayNotFullRequestedPieces) ] ]
]

{ #category : #'measuring rates' }
BtTorrent >> downloadRate [
	^ downloadRate
]

{ #category : #'measuring rates' }
BtTorrent >> downloadRateAverage [
	^ downloadRateAverage 
]

{ #category : #'measuring rates' }
BtTorrent >> downloaded [
	^torrentLock critical: [ downloaded ]
]

{ #category : #'measuring rates' }
BtTorrent >> downloadedAndVerified [
	^ torrentLock critical: [ metainfo length - self left ]
]

{ #category : #'piece control' }
BtTorrent >> files [
	^torrentLock critical: [
		metainfo isMultipleFileMode 
			ifTrue:[
				metainfo files inject: OrderedCollection new into: [ :x :y | 
					| file |
					file:=(y at: 'path') inject: self path into: [ :z :w | z / w].
					x add: file; yourself. 
				] 			  
			]
			ifFalse:[OrderedCollection with: self path ].		  
	]. 
]

{ #category : #'piece control' }
BtTorrent >> halfwayNotFullRequestedPieces [
	^torrentLock
		critical: [ 
			| indeces |
			indeces := self halfwayPieces reject: [ :index | (temporaryPieces at: index + 1) allMissingBlocksAreRequested ].
			indeces
				sort: [ :index1 :index2 | 
					| tempPiece1 tempPiece2 |
					tempPiece1 := temporaryPieces at: index1 + 1.
					tempPiece2 := temporaryPieces at: index2 + 1.
					tempPiece1 requestedBlocks size >= tempPiece2 requestedBlocks size ].
			indeces	 
		]
]

{ #category : #'piece control' }
BtTorrent >> halfwayPieces [
	^ torrentLock
		critical: [ 
			(0 to: metainfo numPieces - 1) asOrderedCollection
				select: [ :pieceIndex | (bitfield at: pieceIndex) = 0 and: [ (temporaryPieces at: pieceIndex + 1) isHalfway ] ] ]
]

{ #category : #'handling received messages' }
BtTorrent >> handleReceivedBitfield: message remotePeer: remotePeer [
	| remoteBitfield |
	remoteBitfield := message payload bitfield.
	remoteBitfield length < metainfo numPieces
		ifTrue: [ self discardRemotePeer: remotePeer ]
		ifFalse: [ 
			remoteBitfield reduceTo: metainfo numPieces.
			torrentLock
				critical: [ 
					remoteBitfield anySpareBitSet
						ifTrue: [ self discardRemotePeer: remotePeer ]
						ifFalse: [ 
							remotePeer bitfield
								ifNotNil: [ 
									| interestingBitfield |
									interestingBitfield := remotePeer bitfield interestingBitfield: remoteBitfield.
									interestingBitfield bitsSet do: [ :index | piecesOnNetwork modifyAt: index by: 1 ] ]
								ifNil: [ remoteBitfield bitsSet do: [ :index | piecesOnNetwork modifyAt: index by: 1 ] ].
							remotePeer
								bitfield: remoteBitfield;
								updateInterest: bitfield ] ] ]
]

{ #category : #'handling received messages' }
BtTorrent >> handleReceivedBlock: message remotePeer: remotePeer [
	| block pieceIndex offset tempPiece blockRequest |
	pieceIndex := message payload index.
	offset := message payload begin.
	block := message payload block.
	blockRequest := BtBlockRequest pieceIndex: pieceIndex offset: offset length: block size.
	torrentLock
		critical: [ 
			(remotePeer unfulfilledOutgoingRequests includes: blockRequest)
				ifTrue: [ 
					self broadcastCancel: pieceIndex begin: offset length: block size.
					self increaseDownloadedBy: block size.
					tempPiece := temporaryPieces at: pieceIndex + 1.
					tempPiece
						at: offset put: block;
						clearRequest: offset.
					tempPiece isComplete
						ifTrue: [ 
							| piece |
							self log: 'TEMPORARY PIECE ' , pieceIndex asString , ' COMPLETE'.
							piece := tempPiece asByteArray.
							(SHA1 hashStream: piece readStream) = (metainfo sha1Of: pieceIndex) asByteArray
								ifTrue: [ 
									fileCollection writeOffset: pieceIndex * metainfo pieceLength data: piece.
									bitfield set: pieceIndex.
									remotePeers doUpdateInterest: bitfield .
									self broadcastHave: pieceIndex ]
								ifFalse: [ self log: 'TEMPORARY PIECE ' , pieceIndex asString , ' CORRUPT' ].
							tempPiece reset ].
					remotePeer updateLastBlockReceivedTime.
					remotePeer increaseUploadedBy: block size.
					remotePeers
						remove: remotePeer;
						add: remotePeer.
					remotePeer unfulfilledOutgoingRequests remove: blockRequest ifAbsent: [ nil ] ] ]
]

{ #category : #'handling received messages' }
BtTorrent >> handleReceivedCancel: message remotePeer: remotePeer [
]

{ #category : #'handling received messages' }
BtTorrent >> handleReceivedChoke: message remotePeer: remotePeer [
	torrentLock
		critical: [ 
			remotePeer acceptsMe: false.
			remotePeer discardUnfulfilledOutgoingRequests.
			remotePeer unfulfilledOutgoingRequests removeAll.
			self clearUnfulfilledOutgoingRequestsThatAreMissingOnNetwork ]
]

{ #category : #'handling received messages' }
BtTorrent >> handleReceivedHave: message remotePeer: remotePeer [
	torrentLock
		critical: [ 
			| index |
			index := message payload index.
			(remotePeer setPieceAt: index)
				ifTrue: [ 
					piecesOnNetwork modifyAt: index by: 1.
					((bitfield at: index) = 0 and: [ remotePeer isInteresting not ])
						ifTrue: [ remotePeer setInteresting ] ] ]
]

{ #category : #'handling received messages' }
BtTorrent >> handleReceivedInterested: message remotePeer: remotePeer [
	torrentLock
		critical: [ 
			self newRemotePeerInterested: remotePeer.
			remotePeer isInterested: true ]
]

{ #category : #'handling received messages' }
BtTorrent >> handleReceivedMessage: message remotePeer: remotePeer [
	message type
		ifNotNil: [ 
			message type = BtMessage chokeMessageType
				ifTrue: [ 
					self handleReceivedChoke: message remotePeer: remotePeer.
					self log: 'CHOKE message handled from ' , remotePeer asString ]
				ifFalse: [ 
					message type = BtMessage unchokeMessageType
						ifTrue: [ 
							self handleReceivedUnchoke: message remotePeer: remotePeer.
							self log: 'UNCHOKE message handled from ' , remotePeer asString ]
						ifFalse: [ 
							message type = BtMessage interestedMessage
								ifTrue: [ 
									self handleReceivedInterested: message remotePeer: remotePeer.
									self log: 'INTERESTED message handled from ' , remotePeer asString ]
								ifFalse: [ 
									message type = BtMessage notInterestedMessageType
										ifTrue: [ 
											self handleReceivedNotInterested: message remotePeer: remotePeer.
											self log: 'NOT INTERESTED message handled from ' , remotePeer asString ]
										ifFalse: [ 
											message type = BtMessage haveMessageType
												ifTrue: [ 
													self handleReceivedHave: message remotePeer: remotePeer.
													self log: 'HAVE: ' , message payload asString , ' message handled from ' , remotePeer asString ]
												ifFalse: [ 
													message type = BtMessage bitfieldMessageType
														ifTrue: [ 
															self handleReceivedBitfield: message remotePeer: remotePeer.
															self log: message payload asString , ' message handled from ' , remotePeer asString ]
														ifFalse: [ 
															message type = BtMessage requestMessageType
																ifTrue: [ 
																	self handleReceivedRequest: message remotePeer: remotePeer.
																	self log: 'REQUEST: ' , message payload asString , ' message handled from ' , remotePeer asString ]
																ifFalse: [ 
																	message type = BtMessage pieceMessageType
																		ifTrue: [ 
																			self handleReceivedBlock: message remotePeer: remotePeer.
																			self log: 'PIECE: ' , message payload asString , ' message handled from ' , remotePeer asString ]
																		ifFalse: [ 
																			message type = BtMessage cancelMessageType
																				ifTrue: [ 
																					self handleReceivedCancel: message remotePeer: remotePeer.
																					self log: 'CANCEL: ' , message payload asString , ' message handled from ' , remotePeer asString ]
																				ifFalse: [ 
																					message type = BtMessage portMessageType
																						ifTrue: [ self log: 'PORT: ' , message payload asString , ' message handled from ' , remotePeer asString ] ] ] ] ] ] ] ] ] ] ]
		ifNil: [ self log: 'KEEP-ALIVE message handled from ' , remotePeer asString ].
	remotePeer updateLastMessageReceivedTime
]

{ #category : #'handling received messages' }
BtTorrent >> handleReceivedNotInterested: message remotePeer: remotePeer [
	torrentLock
		critical: [ 
			self newRemotePeerNotInterested: remotePeer.
			remotePeer isInterested: false. 
		]
]

{ #category : #'handling received messages' }
BtTorrent >> handleReceivedRequest: message remotePeer: remotePeer [
	| payload block pieceIndex |
	remotePeer isAccepted
		ifFalse: [ ^ self ].
	payload := message payload.
	pieceIndex := payload index.
	torrentLock
		critical: [ 
			remotePeer isAccepted
				ifTrue: [ 
					(bitfield at: pieceIndex) = 1
						ifTrue: [ 
							block := fileCollection readOffset: pieceIndex * metainfo pieceLength + payload begin amount: payload length.
							remotePeer sendPiece: payload index begin: payload begin block: block.
							remotePeer increaseDownloadedBy: block size.
							self increaseUploadedBy: payload length.
							remotePeers
								remove: remotePeer;
								add: remotePeer ] ] ]
]

{ #category : #'handling received messages' }
BtTorrent >> handleReceivedUnchoke: message remotePeer: remotePeer [
	torrentLock critical: [ remotePeer acceptsMe: true ]
]

{ #category : #comparing }
BtTorrent >> hash [
	^torrentLock critical: [ metainfo hash ]
]

{ #category : #accessing }
BtTorrent >> id [
	^ id
]

{ #category : #accessing }
BtTorrent >> id: anObject [
	id := anObject
]

{ #category : #'measuring rates' }
BtTorrent >> increaseDownloadedBy: amount [
	torrentLock critical: [ downloaded increaseBy: amount ]
]

{ #category : #'measuring rates' }
BtTorrent >> increaseUploadedBy: amount [
	torrentLock critical: [ uploaded increaseBy: amount ]
]

{ #category : #'initialize-release' }
BtTorrent >> initialize [
	super initialize.
	tracker:= nil.
	remotePeers:= BtRemotePeerCollection notCompleteMode .
	port:= 0.
	multitracker:= BtMultitracker new.		
	fileCollection := BtFileCollection new.
	temporaryPieces := OrderedCollection new.	
	maxPeersAccepted:= DefaultMaxPeersAccepted .		
	maxConnections:= DefaultMaxConnections .
	maxUnfulfilledOutgoingRequestsPerPeer := DefaultMaxUnfulfilledOutgoingRequestsPerPeer .
	id := 0.		
	blockSize:= self class defaultBlockSize.
	isInMultitrackerMode := false.
	torrentLock := Monitor new.
	numPiecesDuringMostCommonPolicy := 4.
	downloadMode := SmartMode .
	self initializeProcesses .
	isActive:=false.
	self initializeState.
	debug:= false.
]

{ #category : #'initialize-release' }
BtTorrent >> initializeChoking [
	choking ifNotNil: [ choking terminate ].
	choking := BtExecutableBlock new
		block: [ 
			[ 
			| stream |
			self updateChokingStatus.
			remotePeers doRestartMeasuringRates.
			(Delay forSeconds: 10) wait.
			stream := WriteStream with: 'Choke iteration. Peers accepted: '.
			stream nextPutAll: String cr.
			(remotePeers select: [ :peer | peer isAccepted ])
				do: [ :p | 
					stream
						nextPutAll: p asString;
						nextPutAll: String cr ].
			self log: stream contents.
			Processor yield ] repeat ]
]

{ #category : #'initialize-release' }
BtTorrent >> initializeInitialChecking [
	initialChecking ifNotNil: [ initialChecking terminate ].
	initialChecking := BtExecutableBlock new
		block: [
			torrentLock critical: [  
				self checkPieces.
				self log: 'checking complete'.
				self isComplete
					ifTrue: [ 
						self log: 'previous state: already complete'.
						alreadyComplete := true ]
					ifFalse: [ 
						self log: 'previous state: not complete'.
						alreadyComplete := false ].					
			] .		
			checkingFinished signal 
		].
]

{ #category : #'initialize-release' }
BtTorrent >> initializeMeasuringRates [
	measuringRates ifNotNil: [ measuringRates terminate ].
	measuringRates := BtExecutableBlock new
		block: [ 
			| period measures |
			measures := 0.
			period := 4.
			[ 
			(Delay forSeconds: period) wait.
			downloadRate byteDisplay amount: (downloaded amount - (lastDownloaded amount)) / period asFloat.
			lastDownloaded amount: downloaded amount.
			uploadRate byteDisplay amount: (uploaded amount - (lastUploaded amount)) / period asFloat.
			lastUploaded amount: uploaded amount.
			self isComplete
				ifFalse: [ downloadRateAverage byteDisplay amount: downloadRateAverage byteDisplay amount + ((downloadRate byteDisplay amount - (downloadRateAverage byteDisplay amount)) / (measures + 1)) asFloat ].
			uploadRateAverage byteDisplay amount: uploadRateAverage byteDisplay amount + ((uploadRate byteDisplay amount - (uploadRateAverage byteDisplay amount)) / (measures + 1)) asFloat.
			measures := measures + 1.
			Processor yield.
			true ] whileTrue ]
]

{ #category : #'initialize-release' }
BtTorrent >> initializeOptimisticChoking [
	optimisticChoking ifNotNil: [ optimisticChoking terminate ].
	optimisticChoking := BtExecutableBlock new
		block: [ 
			[ 
			self updateLuckyPeer.
			(Delay forSeconds: 30) wait.
			Processor yield ] repeat ]
]

{ #category : #'initialize-release' }
BtTorrent >> initializeProcesses [
	self initializeInitialChecking .
	self initializeStarting .
	self initializeTrackerRequesting .
	self initializeChoking .
	self initializeOptimisticChoking . 
	self initializeReceiving.
	self initializeStopping.
	self initializeMeasuringRates .
	self initializeRequesting .
]

{ #category : #'initialize-release' }
BtTorrent >> initializeProcessesNames [
	|name|
	name:= self asString.
	initialChecking name: name, ' Checking content'.
	choking name: name, ' Choking'.
	optimisticChoking name: name , ' Optimistic choking'.
	receiving name: name , ' Receiving'.
	starting name: name , ' Starting'.
	stopping name: name , ' Stopping' .
	trackerRequesting name: name , ' Tracker requesting'.
	measuringRates name: name, ' Measuring rates'.
	requesting name: name, ' Requesting'.
]

{ #category : #'initialize-release' }
BtTorrent >> initializeReceiving [
	receiving ifNotNil: [ receiving terminate ].
	receiving := BtExecutableBlock new
		block: [ 
			[ 
			torrentLock
				critical: [ 
					| peersToDiscard size index |
					peersToDiscard := OrderedCollection new.
					size := remotePeers size.
					index := 1.
					[ index <= size ]
						whileTrue: [ 
							| peer |
							peer := remotePeers at: index.
							peer secondsSinceLastReceivedMessage > BtMessage connectionTimeOut
								ifTrue: [ self discardRemotePeer: peer ]
								ifFalse: [ 
									| message |
									message := peer dequeueNextReceivedMessage.
									message ifNotNil: [ self handleReceivedMessage: message remotePeer: peer ] ].
							remotePeers size = size
								ifTrue: [ index := index + 1 ]
								ifFalse: [ size := size - 1 ] ] ].
			Processor yield ] repeat ]
]

{ #category : #'initialize-release' }
BtTorrent >> initializeRequesting [
	requesting ifNotNil: [ requesting terminate ].
	requesting := BtExecutableBlock new
		block: [ 
			[ 
			self isComplete
				ifTrue: [ self discardSeeders ]
				ifFalse: [ self doRequesting ].
			Processor yield ] repeat ]
]

{ #category : #'initialize-release' }
BtTorrent >> initializeStarting [
	starting ifNotNil: [ starting terminate ].
	starting := BtExecutableBlock new
		block: [ 
			self log: 'resuming'.
			self initializeState .
			self log: 'checking...'.
			checkingFinished := Semaphore new.
			initialChecking resume.
			checkingFinished wait.
			measuringRates resume. 
			choking resume.
			optimisticChoking resume.
			receiving resume.
			requesting resume.			
			trackerRequesting resume.
		].
]

{ #category : #'initialize-release' }
BtTorrent >> initializeState [
	torrentLock critical: [ 
		uploaded:= BtByteDisplay new.
		lastUploaded:= BtByteDisplay new.
		uploadRate:= BtByteRateDisplay new.
		uploadRateAverage := BtByteRateDisplay new .
		downloaded:= BtByteDisplay new.
		lastDownloaded:= BtByteDisplay new.
		downloadRate := BtByteRateDisplay new.
		downloadRateAverage := BtByteRateDisplay new
	].
	started:= false.
	stopPending:=false.
]

{ #category : #'initialize-release' }
BtTorrent >> initializeStopping [
	stopping ifNotNil: [ stopping terminate ].
	stopping := BtExecutableBlock new
		block: [ 
			| lastAnnounceRequestTime |
			self log: 'Stopping'.
			self terminateProcesses.
			self selectFirstTracker.
			self currentTracker isUDP
				ifTrue: [ lastAnnounceRequestTime := self currentTracker lastAnnounceRequestTime ].
			stopPending := true.
			self updateAnnounceRequest.
			stopPending := false.
			self log: 'Sending stopped event'.
			self currentTracker announce.
			self currentTracker isUDP
				ifTrue: [ 
					| time |
					time := Time millisecondClockValue.
					[ 
					self currentTracker lastAnnounceRequestTime = lastAnnounceRequestTime
						and: [ (Time millisecondsSince: time) < (DefaultMaxSecondsForStopping * 1000) ] ]
						whileTrue: [ (Delay forMilliseconds: 100) wait ] ].
			self log: 'Stopping UDP tracker connections'.
			self stopUDPTrackerConnections.
			self log: 'Stopped' ].
	stopping priority: Processor userBackgroundPriority + 1
]

{ #category : #'initialize-release' }
BtTorrent >> initializeTrackerRequesting [
	trackerRequesting ifNotNil: [ trackerRequesting terminate ].
	trackerRequesting := BtExecutableBlock new
		block: [ 
			[ 
			self shouldAnnounce
				ifTrue: [ self doAnnounce ].
			(Delay forSeconds: 1) wait.
			Processor yield ] repeat ]
]

{ #category : #testing }
BtTorrent >> isActive [
	^ torrentLock critical: [ isActive ]
]

{ #category : #testing }
BtTorrent >> isComplete [
	^torrentLock critical: [ bitfield isComplete ] 
]

{ #category : #'piece control' }
BtTorrent >> isInEndGame [
	^ torrentLock
		critical: [ 
			self isComplete not
				and: [ bitfield bitsClear allSatisfy: [ :index | (temporaryPieces at: index + 1) allMissingBlocksAreRequested ] ] ]
]

{ #category : #'peer discovery' }
BtTorrent >> isInMultitrackerMode [
	^torrentLock critical: [ isInMultitrackerMode ]
]

{ #category : #'piece control' }
BtTorrent >> isUsingLowestPolicy [
	^ torrentLock
		critical: [ self isInEndGame not and: [ self isUsingStreamingMode ] ]
]

{ #category : #'piece control' }
BtTorrent >> isUsingMostCommonPolicy [
	^ torrentLock
		critical: [ self isInEndGame not and: [ bitfield numBitsSet between: 0 and: numPiecesDuringMostCommonPolicy - 1 ] ]
]

{ #category : #'piece control' }
BtTorrent >> isUsingRarestPolicy [
	^ torrentLock
		critical: [ 
			self isInEndGame not
				and: [ bitfield numBitsSet between: numPiecesDuringMostCommonPolicy and: metainfo numPieces ] ]
]

{ #category : #'piece control' }
BtTorrent >> isUsingSmartMode [
	^ torrentLock critical: [ downloadMode = SmartMode ]
]

{ #category : #'piece control' }
BtTorrent >> isUsingStreamingMode [
	^torrentLock critical: [ downloadMode = StreamingMode ]
]

{ #category : #'peer discovery' }
BtTorrent >> lastAnnounceEventIsCompleted [
	|event|
	event:=self currentTracker announceRequest event.
	^self currentTracker isHTTP
		ifTrue:[ event = BtHTTPAnnounceQuery completedEvent ]
		ifFalse:[ event = BtUDPAnnounceRequest completedEvent ].
]

{ #category : #P2P }
BtTorrent >> lazyBitfieldTo: remotePeer [
	| missingIndeces indeces lazyBitfield |
	indeces := OrderedCollection withAll: (0 to: metainfo numPieces - 1).
	missingIndeces := OrderedCollection new.
	1 to: (25 min: indeces size) do: [ :v | missingIndeces add: (indeces remove: indeces atRandom) ].
	lazyBitfield := bitfield copy.
	missingIndeces do: [ :index | lazyBitfield clear: index ].
	remotePeer sendBitfield: lazyBitfield.
	missingIndeces do: [ :index | remotePeer sendHave: index ]
]

{ #category : #'piece control' }
BtTorrent >> left [
	^ torrentLock
		critical: [ 
			| pieceLength havePieces numPieces length |
			pieceLength := metainfo pieceLength.
			havePieces := bitfield numBitsSet.
			numPieces := metainfo numPieces.
			length := metainfo length.
			(bitfield at: numPieces - 1) = 1
				ifTrue: [ length - ((havePieces - 1) * pieceLength + metainfo lastPieceLength) ]
				ifFalse: [ length - (havePieces * pieceLength) ] ]
]

{ #category : #accessing }
BtTorrent >> location [
	^ location
]

{ #category : #accessing }
BtTorrent >> location: newLocation [
	torrentLock critical: [  
		location ifNil:[
				metainfo 
					ifNil:[self error: 'metainfo is nil']
					ifNotNil: [
						location := newLocation .
						metainfo isSingleFileMode 
							ifTrue:[self path ensureCreateFile ]
							ifFalse:[self path ensureCreateDirectory ].	
						self updateFileCollection.	  
					] 
			] ifNotNil: [ 
				location ~= newLocation 
					ifTrue:[
						self path moveTo: newLocation / (metainfo name).
						location := newLocation.
						self updateFileCollection.
					].
			].		
	]
]

{ #category : #printing }
BtTorrent >> log: aString [
	debug
		ifFalse: [ ^ self ].
	self crLog.
	aString crLog
]

{ #category : #'piece control' }
BtTorrent >> lowestPiecesOnNetwork [
	^torrentLock critical: [ self lowestPiecesOnNetworkGreaterThan: -1 ]
]

{ #category : #'piece control' }
BtTorrent >> lowestPiecesOnNetworkGreaterThan: index [
	"Devuelve una colección de indices de piezas ordenada ascendientemente por número de índice. Las piezas sin ocurrencias, o que el peer local ya tiene, o que tienen un índice menor o igual que index no aparecen en la colección."

	^ torrentLock
		critical: [ 
			| lowestPieces |
			piecesOnNetwork hasIndexMode
				ifFalse: [ piecesOnNetwork setIndexMode ].
			lowestPieces := (piecesOnNetwork selectExistingPieces reject: [ : i | (bitfield at: i) = 1 or:[i<=index] ])
				asOrderedCollection ]
]

{ #category : #P2P }
BtTorrent >> maxConnections [
	^torrentLock critical: [ maxConnections ]
]

{ #category : #P2P }
BtTorrent >> maxConnections: anInteger [
	torrentLock
		critical: [ 
			maxConnections := anInteger.
			self reduceExcessOfRemotePeers ]
]

{ #category : #P2P }
BtTorrent >> maxPeersAccepted [
	^torrentLock critical: [ maxPeersAccepted ]
]

{ #category : #'private - P2P - requesting' }
BtTorrent >> maxUnfulfilledOutgoingRequestsPerPeer [
	^ torrentLock critical: [ maxUnfulfilledOutgoingRequestsPerPeer ]
]

{ #category : #'private - P2P - requesting' }
BtTorrent >> maxUnfulfilledOutgoingRequestsPerPeer: anInteger [
	torrentLock critical: [ maxUnfulfilledOutgoingRequestsPerPeer := anInteger ]
]

{ #category : #accessing }
BtTorrent >> metainfo [
	^torrentLock critical: [ metainfo ]
]

{ #category : #accessing }
BtTorrent >> metainfo: newMetainfo [
	torrentLock
		critical: [ 
			(metainfo isNil or: [ metainfo hash ~= newMetainfo hash ])
				ifTrue: [ 
					bitfield := BtBitfield new: newMetainfo numPieces.
					self updateTrackers: newMetainfo.
					metainfo := newMetainfo.
					self debug: debug.
					self initializeProcessesNames.
					location ifNotNil: [ self updateFileCollection ].
					self updateTemporaryPieces.
					self updatePiecesOnNetwork.
					(isInMultitrackerMode and: [ metainfo supportMultitracker not ])
						ifTrue: [ isInMultitrackerMode := false ] ] ]
]

{ #category : #'piece control' }
BtTorrent >> missingPiecesOffsets [
	^ torrentLock critical: [ bitfield bitsClear collect: [ :index | index * metainfo pieceLength ] ]
]

{ #category : #'piece control' }
BtTorrent >> missingPiecesOnNetwork [
	^ torrentLock critical: [ piecesOnNetwork selectMissingPieces ]
]

{ #category : #P2P }
BtTorrent >> modifyMaxConnectionsBy: anInteger [
	torrentLock critical: [ self maxConnections: (maxConnections + anInteger max: 0) ]
]

{ #category : #'piece control' }
BtTorrent >> mostCommonPiecesOnNetwork [
	"Devuelve una colección de indices de piezas ordenada descendientemente por número de ocurrencias. Las piezas sin ocurrencias o que el peer local ya tiene no aparecen en la colección."

	^ torrentLock
		critical: [ 
			| mostCommonPieces |
			piecesOnNetwork hasRarityMode
				ifFalse: [ piecesOnNetwork setRarityMode ].
			mostCommonPieces := (piecesOnNetwork selectExistingPieces reject: [ :index | (bitfield at: index) = 1 ]) reversed
				asOrderedCollection ]
]

{ #category : #'peer discovery' }
BtTorrent >> moveCurrentTrackerToFirstInTier [
	self isInMultitrackerMode
		ifFalse: [ ^ self ].
	self log: 'multitracker mode: current tracker moved to first position in tier'.
	multitracker moveCurrentToFirst
]

{ #category : #'peer discovery' }
BtTorrent >> multitracker [
	^ multitracker
]

{ #category : #'peer discovery' }
BtTorrent >> multitracker: anObject [
	multitracker := anObject
]

{ #category : #'peer discovery' }
BtTorrent >> newHTTPAnnounceRequest [
	^ torrentLock
		critical: [ 
			| announceRequest |
			announceRequest := BtHTTPAnnounceQuery new.
			announceRequest
				infoHash: metainfo hash;
				peerID: id;
				node:
						(BtNode new
								domain: (BtDomain new address: 0);
								port: port);
				uploaded: self uploaded amount;
				downloaded: self downloaded amount;
				left: self left;
				compact: 1;
				noPeerID: 1;
				numWant: 0.
			announceRequest setNone.
			stopPending
				ifTrue: [ announceRequest setStopped ]
				ifFalse: [ 
					started
						ifFalse: [ 
							announceRequest setStarted.
							self isComplete
								ifFalse: [ announceRequest numWant: self numNewConnectionsDesired * 100 ] ]
						ifTrue: [ 
							self isComplete
								ifTrue: [ 
									alreadyComplete
										ifFalse: [ announceRequest setCompleted ] ]
								ifFalse: [ announceRequest numWant: self numNewConnectionsDesired * 100 ] ] ].
			announceRequest ]
]

{ #category : #P2P }
BtTorrent >> newRemotePeerInterested: remotePeer [
	remotePeer isLucky
		ifTrue: [ 
			| acceptedPeers |
			acceptedPeers := remotePeers selectAccepted .
			acceptedPeers size > maxPeersAccepted
				ifTrue: [ 
					acceptedPeers := acceptedPeers difference: (OrderedCollection with: remotePeer).
					self isComplete
						ifTrue: [ acceptedPeers setCompleteMode ]
						ifFalse: [ acceptedPeers setNotCompleteMode ].
					acceptedPeers
						ifNotEmpty: [ 
							| worstPeer |
							worstPeer := acceptedPeers last.
							worstPeer notAccept] ] ]
]

{ #category : #P2P }
BtTorrent >> newRemotePeerNotInterested: remotePeer [
	remotePeer isLucky
		ifTrue: [ 
			| acceptedPeers |
			acceptedPeers := remotePeers selectAccepted.
			acceptedPeers size < maxPeersAccepted
				ifTrue: [ 
					| competitors |
					competitors := remotePeers selectInterested
						reject: [ :peer | peer isLucky or: [ peer isSnubber or: [ peer isAccepted ] ] ].
					competitors
						ifNotEmpty: [ 
							| bestPeer |
							self isComplete
								ifTrue: [ competitors setCompleteMode ]
								ifFalse: [ competitors setNotCompleteMode ].
							bestPeer := competitors first.
							bestPeer accept ] ] ]
]

{ #category : #'peer discovery' }
BtTorrent >> newUDPAnnounceRequest [
	^ torrentLock
		critical: [ 
			| announceRequest |
			announceRequest := BtUDPAnnounceRequest new.
			announceRequest
				infoHash: metainfo hash;
				peerID: id;
				uploaded: self uploaded amount;
				downloaded: self downloaded amount;
				left: self left;
				numWant: 0;
				key: 0;
				node:
						(BtNode new
								domain: (BtDomain new address: 0);
								port: port).
			announceRequest setNone.
			stopPending
				ifTrue: [ announceRequest setStopped ]
				ifFalse: [ 
					started
						ifFalse: [ 
							announceRequest setStarted.
							self isComplete
								ifFalse: [ announceRequest numWant: self numNewConnectionsDesired * 100 ] ]
						ifTrue: [ 
							self isComplete
								ifTrue: [ 
									alreadyComplete
										ifFalse: [ announceRequest setCompleted ] ]
								ifFalse: [ announceRequest numWant: self numNewConnectionsDesired * 100 ] ] ].			
			announceRequest ]
]

{ #category : #P2P }
BtTorrent >> numConnections [
	^torrentLock critical: [ remotePeers size ]
]

{ #category : #'peer discovery' }
BtTorrent >> numNewConnectionsDesired [
	^ torrentLock critical: [ (maxConnections - remotePeers size max: 0) ]
]

{ #category : #'piece control' }
BtTorrent >> numRequestedTemporaryBlocks [
	^torrentLock critical: [ temporaryPieces inject: 0 into: [ :sum :tempPiece | sum + (tempPiece numRequested )]  ]
]

{ #category : #'piece control' }
BtTorrent >> path [
	^ torrentLock critical: [ location / (metainfo name) ]
]

{ #category : #P2P }
BtTorrent >> peersDownloadingFrom [
	^ remotePeers selectWithUnfulfilledOutgoingRequests
]

{ #category : #P2P }
BtTorrent >> peersUploadingTo [
	^ remotePeers selectWithUnfulfilledIncomingRequests 
]

{ #category : #accessing }
BtTorrent >> port [
	^ port
]

{ #category : #accessing }
BtTorrent >> port: newPort [
	port ~= newPort
		ifTrue: [ 
			torrentLock
				critical: [ 
					port := newPort.
					self discardAllRemotePeers ] ]
]

{ #category : #printing }
BtTorrent >> printOn: aStream [
	torrentLock critical: [
		metainfo 
			ifNil: [ super printOn: aStream ]
		 	ifNotNil: [ aStream nextPutAll: metainfo name ] 
	]
]

{ #category : #'piece control' }
BtTorrent >> randomPiecesOnNetwork [
	"Devuelve una colección mezclada de indices de piezas. Las piezas sin ocurrencias o que self ya tiene no aparecen en la colección."

	^ torrentLock
		critical: [ 
			| randomPieces |
			randomPieces := (piecesOnNetwork selectExistingPieces reject: [ :index | (bitfield at: index) = 1 ]) shuffle 
				asOrderedCollection ]
]

{ #category : #'piece control' }
BtTorrent >> rarestPiecesOnNetwork [
	"Devuelve una colección de indices de piezas ordenada ascendientemente por número de ocurrencias. Las piezas sin ocurrencias o que el peer local ya tiene no aparecen en la colección."

	^ torrentLock
		critical: [ 
			| rarestPieces |
			piecesOnNetwork hasRarityMode
				ifFalse: [ piecesOnNetwork setRarityMode ].
			rarestPieces := (piecesOnNetwork selectExistingPieces reject: [ :index | (bitfield at: index) = 1 ])
				asOrderedCollection ]
]

{ #category : #'peer discovery' }
BtTorrent >> readRemotePeersFromAnnounceResponse [
	| newRemotePeers |
	newRemotePeers := self currentTracker isHTTP
		ifTrue: [ self readRemotePeersFromHTTPAnnounceResponse ]
		ifFalse: [ self readRemotePeersFromUDPAnnounceResponse ].
	^ newRemotePeers
		do: [ :peer | 
			peer
				bitfield: (BtBitfield new: metainfo numPieces);
				debug: debug ]
]

{ #category : #'peer discovery' }
BtTorrent >> readRemotePeersFromHTTPAnnounceResponse [
	| peersBinary stream newRemotePeers |
	peersBinary := self currentTracker announceResponse atPeers asByteArray.
	stream := peersBinary readStream.
	newRemotePeers:= BtRemotePeerCollection new.
	[ stream atEnd ]
		whileFalse: [ 
			| remotePeer |
			remotePeer := BtRemotePeer new.
			remotePeer domain address: (stream next: 4) asInteger.
			remotePeer port: (stream next: 2) asInteger.
			newRemotePeers add: remotePeer ].
	^ newRemotePeers	
]

{ #category : #'peer discovery' }
BtTorrent >> readRemotePeersFromUDPAnnounceResponse [
	| aNodeCollection  newRemotePeers |
	aNodeCollection := self currentTracker announceResponse nodeCollection.
	newRemotePeers:= BtRemotePeerCollection new.
	aNodeCollection asOrderedCollection
		do: [ :node | 
			| remotePeer |
			remotePeer := BtRemotePeer new.
			remotePeer domain address: node domain address.
			remotePeer port: node port.
			newRemotePeers add: remotePeer ].
	^ newRemotePeers
]

{ #category : #P2P }
BtTorrent >> reduceExcessOfRemotePeers [
	torrentLock
		critical: [ 
			self isComplete
				ifTrue: [ remotePeers setCompleteMode ]
				ifFalse: [ remotePeers setNotCompleteMode ].
			[ remotePeers isNotEmpty and: [ remotePeers size > maxConnections ] ]
				whileTrue: [ self discardRemotePeer: remotePeers last ] ]
]

{ #category : #'private - P2P - requesting' }
BtTorrent >> requestBlockAt: pieceIndex offset: offset to: remotePeer [
	torrentLock
		critical: [ 
			| tempPiece blockRequest |
			tempPiece := temporaryPieces at: pieceIndex + 1.
			blockRequest := BtBlockRequest pieceIndex: pieceIndex offset: offset length: (tempPiece blockSizeOf: offset).
			remotePeer request: blockRequest.
			tempPiece setRequest: offset.
			self
				log:
					'REQUEST: ' , pieceIndex asString , ' ' , offset asString , ' ' , (tempPiece blockSizeOf: offset) asString , ' TO: '
						, remotePeer asString ]
]

{ #category : #'private - P2P - requesting' }
BtTorrent >> requestMissingAndNotRequestedBlocksAt: pieceIndex [
	| owners missingAndNotRequestedBlocks |
	owners := SortedCollection
		sortBlock: [ :a :b | (a unfulfilledOutgoingRequestsAt: pieceIndex) size <= (b unfulfilledOutgoingRequestsAt: pieceIndex) size ].
	owners addAll: (remotePeers selectAcceptsMe selectPieceOwnersOf: pieceIndex).
	owners := owners reject: [ :peer | peer unfulfilledOutgoingRequests size >= maxUnfulfilledOutgoingRequestsPerPeer ].
	missingAndNotRequestedBlocks := (temporaryPieces at: pieceIndex + 1) missingAndNotRequestedBlocks.
	missingAndNotRequestedBlocks
		do: [ :offset | 
			| owner |
			owners
				ifNotEmpty: [ 
					owner := owners first.
					self log: 'Piece owner: ' , owner asString , ' || ' , 'Piece index: ' , pieceIndex asString.
					self requestBlockAt: pieceIndex offset: offset to: owner.
					owners remove: owner.
					owner unfulfilledOutgoingRequests size >= maxUnfulfilledOutgoingRequestsPerPeer
						ifFalse: [ owners add: owner ] ] ]
]

{ #category : #'P2P - requesting' }
BtTorrent >> requestMissingAndNotRequestedBlocksOf: indexCollection [
	torrentLock critical: [ indexCollection do: [ :pieceIndex | self requestMissingAndNotRequestedBlocksAt: pieceIndex ] ]
]

{ #category : #'private - P2P - requesting' }
BtTorrent >> requestMissingBlocksAt: pieceIndex to: remotePeer [
	torrentLock
		critical: [ 
			| tempPiece offsets blockRequestsOffsets |
			tempPiece := temporaryPieces at: pieceIndex + 1.
			offsets := tempPiece missingBlocks.
			blockRequestsOffsets := (remotePeer unfulfilledOutgoingRequestsAt: pieceIndex)
				collect: [ :blockRequest | blockRequest offset ].
			offsets := offsets reject: [ :offset | blockRequestsOffsets includes: offset ].
			offsets do: [ :offset | self requestBlockAt: pieceIndex offset: offset to: remotePeer ] ]
]

{ #category : #'piece control' }
BtTorrent >> requestedTemporaryBlocks [
	^ torrentLock
		critical: [ 
			| blockRequests |
			blockRequests := OrderedCollection new.
			temporaryPieces
				doWithIndex: [ :piece :index | 
					| pendingBlocks |
					pendingBlocks := piece requestedBlocks.
					blockRequests
						addAll:
							((1 to: pendingBlocks size)
								inject: OrderedCollection new
								into: [ :collection :offsetIndex | 
									| offset |
									offset := pendingBlocks at: offsetIndex.
									collection
										add: (BtBlockRequest pieceIndex: index - 1 offset: offset length: (piece blockSizeOf: offset));
										yourself ]) ].
			blockRequests ]
]

{ #category : #'piece control' }
BtTorrent >> requestedTemporaryPieces [
	^ (0 to: metainfo numPieces - 1)
		select: [ :pieceIndex | (bitfield at: pieceIndex) = 0 and: [ (temporaryPieces at: pieceIndex + 1) hasAnyRequested ] ]
]

{ #category : #operations }
BtTorrent >> restart [
	self
		delete;
		start
]

{ #category : #'peer discovery' }
BtTorrent >> selectFirstTracker [
	self isInMultitrackerMode
		ifFalse: [ ^ self ].
	multitracker selectFirst.
	self log: 'mulitracker mode: first tracker selected'
]

{ #category : #'peer discovery' }
BtTorrent >> selectLastTracker [
	self isInMultitrackerMode
		ifFalse: [ ^ self ].
	multitracker selectLast.
	self log: 'mulitracker mode: last tracker selected'
]

{ #category : #'peer discovery' }
BtTorrent >> selectNextTracker [
	self isInMultitrackerMode
		ifFalse: [ ^ self ].
	multitracker selectNext.
	self log: 'mulitracker mode: next tracker selected'
]

{ #category : #'peer discovery' }
BtTorrent >> setMultitrackerMode [
	torrentLock
		critical: [ 
			metainfo supportMultitracker
				ifFalse: [ self error: 'Metainfo not supporting multitracker mode' ]
				ifTrue: [ isInMultitrackerMode := true ] ]
]

{ #category : #'peer discovery' }
BtTorrent >> setSingletrackerMode [
	isInMultitrackerMode:=false
]

{ #category : #'piece control' }
BtTorrent >> setSmartMode [
	torrentLock critical: [ downloadMode = SmartMode ]
]

{ #category : #'piece control' }
BtTorrent >> setStreamingMode [
	torrentLock critical: [ downloadMode := StreamingMode ]
]

{ #category : #'peer discovery' }
BtTorrent >> shouldAnnounce [
	^ stopPending
		ifTrue: [ true ]
		ifFalse: [ 
			started
				ifFalse: [ true ]
				ifTrue: [ 
					self isComplete
						ifTrue: [ 
							alreadyComplete
								ifTrue: [ 
									| secondsSinceLastAnnounce |
									secondsSinceLastAnnounce := self currentTracker secondsSinceLastAnnounce.
									secondsSinceLastAnnounce ifNil: [ true ] ifNotNil: [ secondsSinceLastAnnounce >= self currentTracker interval ] ]
								ifFalse: [ true ] ]
						ifFalse: [ 
							self numNewConnectionsDesired > 0
								ifTrue: [ 
									true	"| secondsSinceLastAnnounce |
									secondsSinceLastAnnounce := self currentTracker secondsSinceLastAnnounce.
									secondsSinceLastAnnounce ifNil: [ true ] ifNotNil: [ secondsSinceLastAnnounce >= self currentTracker interval ]" ]
								ifFalse: [ false ] ] ] ]
]

{ #category : #operations }
BtTorrent >> start [
	torrentLock
		critical: [ 
			isActive
				ifFalse: [ 
					self initializeProcessesNames.
					starting resume.
					isActive := true ] ]
]

{ #category : #testing }
BtTorrent >> started [
	^ started
]

{ #category : #operations }
BtTorrent >> stop [
	torrentLock
		critical: [ 
			stopping resume.
			isActive := false ]
]

{ #category : #'peer discovery' }
BtTorrent >> stopUDPTrackerConnections [
	tracker isUDP 
		ifTrue:[tracker terminate].
	multitracker tierCollection do:[:tier| tier do:[:aTracker | aTracker isUDP ifTrue:[aTracker terminate]]].
]

{ #category : #'peer discovery' }
BtTorrent >> supportMultitracker [
	^ torrentLock critical: [ metainfo supportMultitracker ]
]

{ #category : #'private - operations' }
BtTorrent >> terminateProcesses [
	starting terminate .
	initialChecking terminate .
	choking terminate .
	optimisticChoking terminate .
	receiving terminate .
	requesting terminate.
	trackerRequesting terminate .
	measuringRates terminate .
	self discardAllRemotePeers.
]

{ #category : #'peer discovery' }
BtTorrent >> tracker [
	^ tracker
]

{ #category : #'P2P - requesting' }
BtTorrent >> unfulfilledOutgoingRequestsAverage [
	| peers |
	peers := remotePeers selectWithUnfulfilledOutgoingRequests .
	^ (peers
		ifEmpty: [ 0 ]
		ifNotEmpty: [ (peers inject: 0 into: [ :sum :v | sum + v unfulfilledOutgoingRequests size ]) / peers size ]) asFloat
]

{ #category : #'piece control' }
BtTorrent >> unfulfilledOutgoingRequestsOnNetwork [
	^torrentLock critical: [ 
		| requestedBlocks |
		requestedBlocks:=OrderedCollection new.
		remotePeers do:[:peer| requestedBlocks addAll: peer unfulfilledOutgoingRequests ].
		requestedBlocks 		 
	]
]

{ #category : #'peer discovery' }
BtTorrent >> updateAnnounceRequest [
	self currentTracker isHTTP 
		ifTrue: [ self currentTracker announceRequest: self newHTTPAnnounceRequest ].
	self currentTracker isUDP
		ifTrue:[self currentTracker announceRequest: self newUDPAnnounceRequest ].							
]

{ #category : #P2P }
BtTorrent >> updateChokingStatus [
	torrentLock
		critical: [ 
			| max candidates candidatesThatDontCompete competitors |
			candidates := remotePeers reject: [ :peer | peer isLucky ].
			candidatesThatDontCompete := candidates select: [ :peer | peer isInterested not or: [ peer isSnubber ] ].
			candidatesThatDontCompete ensureNotAccept.
			competitors := candidates difference: candidatesThatDontCompete.
			self isComplete
				ifTrue: [ competitors setCompleteMode ]
				ifFalse: [ competitors setNotCompleteMode ].
			max := competitors size min: maxPeersAccepted.
			competitors ensureAcceptFirst: max ]
]

{ #category : #'piece control' }
BtTorrent >> updateFileCollection [
	| fileDictionaries |
	fileDictionaries := metainfo files.
	fileCollection := BtFileCollection fromFileDictionaries: fileDictionaries at: self path.
]

{ #category : #P2P }
BtTorrent >> updateLuckyPeer [
	torrentLock
		critical: [ 
			| oldLuckyPeer candidates newLuckyPeer |
			oldLuckyPeer := remotePeers detectLucky.
			candidates := oldLuckyPeer
				ifNil: [ remotePeers rejectAccepted ]
				ifNotNil: [ 
					remotePeers rejectAccepted
						add: oldLuckyPeer;
						yourself ].
			newLuckyPeer := [ candidates atRandom ]
				on: Error
				do: [ :ex | ex return: nil ].
			oldLuckyPeer ~= newLuckyPeer
				ifTrue: [ 
					oldLuckyPeer
						ifNotNil: [ 
							oldLuckyPeer
								notAccept;
								isLucky: false ].
					newLuckyPeer
						ifNotNil: [ 
							maxPeersAccepted > 0
								ifTrue: [ 
									newLuckyPeer
										accept;
										isLucky: true ] ] ]
				ifFalse: [ 
					oldLuckyPeer
						ifNotNil: [ 
							maxPeersAccepted > 0
								ifFalse: [ 
									oldLuckyPeer
										notAccept;
										isLucky: false ] ] ] ]
]

{ #category : #'piece control' }
BtTorrent >> updatePiecesOnNetwork [
	torrentLock
		critical: [ 
			piecesOnNetwork := (piecesOnNetwork isNil or: [ piecesOnNetwork hasRarityMode ])
				ifTrue: [ BtPiecesOnNetwork rarityMode: metainfo numPieces ]
				ifFalse: [ BtPiecesOnNetwork indexMode: metainfo numPieces ] ]
]

{ #category : #P2P }
BtTorrent >> updateRemotePeers [
	| index newRemotePeers |
	torrentLock
		critical: [ 
			| size |
			newRemotePeers := self readRemotePeersFromAnnounceResponse.
			self log: newRemotePeers size asString , ' remote peers received'.
			size := newRemotePeers size.
			index := 1.
			[ index <= size ]
				whileTrue: [ 
					| peer |
					peer := newRemotePeers at: index.
					(remotePeers includes: peer)
						ifTrue: [ 
							newRemotePeers
								remove:
									(peer
										terminate;
										yourself).
							size := size - 1 ]
						ifFalse: [ index := index + 1 ] ] ].
	self log: newRemotePeers size asString , ' are new'.
	[ remotePeers size <= maxConnections and: [ newRemotePeers isNotEmpty ] ]
		whileTrue: [ 
			self connectTo: newRemotePeers removeLast.
			Processor yield ].
	[ newRemotePeers isEmpty ]
		whileFalse: [ 
			newRemotePeers removeLast
				terminate;
				destroy ].
	self log: 'update remote peers completed'
]

{ #category : #'piece control' }
BtTorrent >> updateTemporaryPieces [
	torrentLock
		critical: [ 
			temporaryPieces := (0 to: metainfo numPieces - 1)
				inject: OrderedCollection new
				into: [ :collection :index | 
					collection
						add: (BtTemporaryPiece length: (metainfo pieceLengthOf: index) blockSize: blockSize);
						yourself ] ]
]

{ #category : #'peer discovery' }
BtTorrent >> updateTrackers: newMetainfo [
	| announce |
	newMetainfo supportMultitracker 
		ifTrue: [  
			|announceList|
			announceList:=newMetainfo announceList.			 
			multitracker
				tierCollection: (announceList collect:[:tier | tier collect: [:url | BtTracker on: url asZnUrl ] ]);
				shuffle;
				position: 1;
				tierPosition: 1.
		].
		announce:=newMetainfo announce.
		announce ifNotNil: [ tracker:= (BtTracker on: announce asZnUrl ) ].
]

{ #category : #'measuring rates' }
BtTorrent >> uploadRate [
	^ uploadRate
]

{ #category : #'measuring rates' }
BtTorrent >> uploadRateAverage [
	^ uploadRateAverage 
]

{ #category : #'measuring rates' }
BtTorrent >> uploaded [
	^torrentLock critical: [ uploaded ]
]

{ #category : #'peer discovery' }
BtTorrent >> waitForUDPAnnounceResponse [
	| seconds count |
	seconds:=7.
	count:=0.
	[ count<seconds and:[ self currentTracker announceHasFailed ]]
		whileTrue: [ 
			(Delay forSeconds: 1) wait .
			count:=count+1 
		].
]
