"
Utilization example:
-------------------------------------------------------------------------------------------------------------------------------------
If I am the creator of the .torrent:

locationString:= '/home/david/directoryIWantToShare' .

metainfo:=BtMetainfo new 
				buildOn: locationString asFileReference 
				announce: 'udp://open.demonii.com:1337/announce' 
				pieceLength: (2 raisedTo: 14).

(It's needed upload this file to a torrent index )
metainfo writeToFile: '/home/david/myMetainfo.torrent' asFileReference . 

metainfoString := '/home/david/myMetainfo.torrent'.

-------------------------------------------------------------------------------------------------------------------------------------
If I am not the creator of the .torrent:

locationString:='/home/david/BitTalk/destinationFolder'.

(It's needed download a file .torrent from a torrent index)
metainfoString:='/home/david/BitTalk/[kat.cr]the.hollow.2015.hdrip.xvid.etrg.torrent'. 

-------------------------------------------------------------------------------------------------------------------------------------
Common part:

torrent:= BtTorrent metainfoFileString: metainfoString locationString: locationString.

localPeer:= BtLocalPeer start.
localPeer addTorrent: torrent.
torrent start.
------------------------------------------------------------------------------------------------------------------------------------	
Maybe you want to stop a specific torrent only:

torrent stop.	
	
-------------------------------------------------------------------------------------------------------------------------------------
To stop local peer (and all its torrents):

localPeer stop.
"
Class {
	#name : #BtLocalPeer,
	#superclass : #BtPeer,
	#instVars : [
		'torrents',
		'receiverSocket',
		'isRunning',
		'maxConnections',
		'listening',
		'localPeerLock',
		'managing'
	],
	#classVars : [
		'DefaultMaxConnections'
	],
	#category : #BitTalk
}

{ #category : #accessing }
BtLocalPeer class >> defaultMaxConnections [
	^ DefaultMaxConnections
]

{ #category : #operations }
BtLocalPeer class >> generatePeerID [
	| stream |
	stream := WriteStream with: ByteArray new.
	stream
		nextPut: $- asInteger;
		nextPutAll: 'bt' asByteArray;
		nextPutAll: ((10000 atRandom - 1) asString padLeftTo: 4 with: $0) asByteArray;
		nextPut: $- asInteger;
		nextPutAll: ((2 raisedTo: 96) atRandom - 1) asByteArray.
	^ stream contents asInteger
]

{ #category : #operations }
BtLocalPeer class >> generateRandomPort [
	^(49160 to: 65534) atRandom
]

{ #category : #'initialize-release' }
BtLocalPeer class >> initialize [
	super initialize.
	DefaultMaxConnections := 20.
]

{ #category : #'instance creation' }
BtLocalPeer class >> new [
	| instances |
	instances := self allInstances.
	^ instances ifEmpty: [ super new ] ifNotEmpty: [ instances first ]
]

{ #category : #'instance creation' }
BtLocalPeer class >> start [
	^ (self new) start
]

{ #category : #operations }
BtLocalPeer >> addTorrent: aTorrent [
	localPeerLock
		critical: [ 
			(torrents includes: aTorrent)
				ifFalse: [ 
					aTorrent
						id: id;
						port: port.
					debug
						ifTrue: [ aTorrent debug: true ].
					torrents add: aTorrent ] ]
]

{ #category : #accessing }
BtLocalPeer >> debug: aBoolean [
	super debug: aBoolean .
	torrents do:[:t| t debug: aBoolean].
]

{ #category : #'private - operations' }
BtLocalPeer >> giveHandshake: remotePeer [
	| handshake |
	handshake := remotePeer receiveHandshake.
	remotePeer id: handshake peerID.
	handshake protocolIdentifier = BtHandshakeMessage protocolIdentifier
		ifFalse: [ BtHandshakeError signal ]
		ifTrue: [ 
			| infoHash torrent |
			infoHash := handshake infoHash.
			torrent := torrents detect: [ :each | each hash = infoHash ] ifNone: [ nil ].
			torrent
				ifNil: [ BtHandshakeError signal ]
				ifNotNil: [ 
					torrent numConnections < torrent maxConnections
						ifTrue: [ 
							remotePeer sendHandshake: torrent hash id: id.
							remotePeer resume.
							^ torrent ]
						ifFalse: [ BtMaxConnectionsReached signal ] ] ]
]

{ #category : #'initialize-release' }
BtLocalPeer >> initialize [
	super initialize.
	torrents := OrderedCollection new.
	id := self class generatePeerID.
	localPeerLock := Monitor new.
	maxConnections := DefaultMaxConnections.
	receiverSocket := Socket newTCP.
	self initializeProcesses.
	self port: self class generateRandomPort.
]

{ #category : #'initialize-release' }
BtLocalPeer >> initializeListening [
	listening ifNotNil: [ listening terminate ].
	listening := BtExecutableBlock new
		block: [
			[ true ]
				whileTrue: [ 
					self receiveConnection.
					Processor yield ] ]
]

{ #category : #'initialize-release' }
BtLocalPeer >> initializeManaging [
	managing ifNotNil: [ managing terminate ].
	managing := BtExecutableBlock new
		block: [ 
			[ true ]
				whileTrue: [ 
					self updateConnectionsPerTorrent.
					(Delay forSeconds: 1) wait.
					Processor yield ] ]
]

{ #category : #'initialize-release' }
BtLocalPeer >> initializeProcesses [
	self initializeListening .
	self initializeManaging .
]

{ #category : #'initialize-release' }
BtLocalPeer >> initializeProcessesNames [
	|name|
	name:= self asString.
	listening name: name , ' Listening' .
	managing name: name , ' Managing' .
]

{ #category : #'initialize-release' }
BtLocalPeer >> initializeReceiverSocket [
	receiverSocket ifNotNil: [ receiverSocket closeAndDestroy ].
	receiverSocket := Socket newTCP.
	receiverSocket listenOn: port backlogSize: 10
]

{ #category : #accessing }
BtLocalPeer >> isRunning [
	^ localPeerLock critical: [ isRunning ]
]

{ #category : #accessing }
BtLocalPeer >> maxConnections [
	^ maxConnections
]

{ #category : #accessing }
BtLocalPeer >> maxConnections: anObject [
	maxConnections := anObject
]

{ #category : #accessing }
BtLocalPeer >> port: newPort [
	port ~= newPort
		ifTrue: [ 
			super port: newPort.
			self initializeProcessesNames.
			receiverSocket listenOn: newPort backlogSize: 10.
			torrents do: [ :torrent | torrent port: newPort ] ]
]

{ #category : #printing }
BtLocalPeer >> printOn: aStream [
	aStream
		nextPutAll: 'Local peer[';
		nextPutAll: domain address asIPv4 dotted;
		nextPutAll: ':';
		nextPutAll: port asString;
		nextPutAll: ']'
]

{ #category : #operations }
BtLocalPeer >> receiveConnection [
	| remotePeer |
	remotePeer := self waitForConnectionFor: 1.
	remotePeer
		ifNotNil: [ 
			[ 
			| torrent |
			torrent := [ self giveHandshake: remotePeer	"Transcript show: 'Exito'; cr" ]
				on: ConnectionTimedOut , BtMessageError , BtHandshakeError , BtMaxConnectionsReached
				do: [ :ex | 
					"Transcript show: 'Error en la conexión: ' , ex asString; cr."
					remotePeer
						terminate;
						destroy.
					ex return: nil ].
			torrent
				ifNotNil: [ 
					torrent addRemotePeer: remotePeer.
					self log: 'torrent: ' , torrent asString , ' added'	"Transcript show: 'peer remoto añadido'; cr." ] ]
				forkAt: Processor userBackgroundPriority ]
]

{ #category : #operations }
BtLocalPeer >> removeTorrent: aTorrent [
	localPeerLock
		critical: [ 
			(torrents includes: aTorrent)
				ifTrue: [ 
					aTorrent stop.
					torrents remove: aTorrent ] ]
]

{ #category : #operations }
BtLocalPeer >> start [
	localPeerLock
		critical: [ 
			isRunning := true.
			receiverSocket isUnconnectedOrInvalid
				ifTrue: [ self initializeReceiverSocket  ].
			listening resume ]
]

{ #category : #operations }
BtLocalPeer >> stop [
	localPeerLock
		critical: [ 
			isRunning := false.
			self stopAllTorrents.
			torrents removeAll.
			self terminateProcesses.
			receiverSocket closeAndDestroy ]
]

{ #category : #'private - operations' }
BtLocalPeer >> stopAllTorrents [
	torrents do: [ :torrent | torrent stop ].
]

{ #category : #'private - operations' }
BtLocalPeer >> terminateProcesses [
	listening terminate .
	managing terminate .
]

{ #category : #accessing }
BtLocalPeer >> torrents [
	^ localPeerLock critical: [ torrents ]
]

{ #category : #operations }
BtLocalPeer >> updateConnectionsPerTorrent [
	| remaining index activeTorrents numTorrents connectionsPerTorrent |
	remaining := maxConnections.
	activeTorrents := torrents select: [ :torrent | torrent isActive ].
	numTorrents := activeTorrents size.
	connectionsPerTorrent := [ maxConnections quo: numTorrents ]
		on: ZeroDivide
		do: [ :ex | ex return: nil ].
	connectionsPerTorrent ifNil: [ ^ self ].
	activeTorrents do: [ :torrent | torrent maxConnections: connectionsPerTorrent ].
	remaining := maxConnections rem: numTorrents.
	index := 1.
	[ remaining > 0 and: [ index <= numTorrents ] ]
		whileTrue: [ 
			(activeTorrents at: index) modifyMaxConnectionsBy: 1.
			remaining := remaining - 1.
			index := index + 1 ]
]

{ #category : #'private - operations' }
BtLocalPeer >> waitForConnectionFor: seconds [
	|  newSocket |
	newSocket := receiverSocket waitForAcceptFor: seconds ifTimedOut: [ nil ].
	^ newSocket
		ifNil:[ nil ]
		ifNotNil: [ 
			self log: 'new socket'.	"Transcript show: 'Conexión entrante'; cr."
			(BtRemotePeer on: (SocketStream on: newSocket)) debug: debug ]
]
