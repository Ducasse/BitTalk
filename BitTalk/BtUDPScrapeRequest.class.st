"
A BtUDPScrapeRequestPacket is xxxxxxxxx.

Instance Variables
	infoHashCollection:		<Object>

infoHashCollection
	- xxxxx

"
Class {
	#name : #BtUDPScrapeRequest,
	#superclass : #BtUDPConnectRequest,
	#instVars : [
		'infoHashCollection'
	],
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #'converting-arrays' }
BtUDPScrapeRequest >> asByteArray [
	| maxTorrents infoHashCollectionSize stream |
	maxTorrents:=(BtUDPTracker maxTorrentsScraped).
	infoHashCollectionSize:= infoHashCollection size.
	infoHashCollectionSize > maxTorrents
		ifTrue:[BtMaxTorrentsScrapedExceeded signal].
	stream:= WriteStream with: ByteArray new.
	stream nextPutAll: super asByteArray .
	infoHashCollection do: [:infoHash | stream nextPutAll: (infoHash asByteArrayOfSize: 20) ].
	^stream contents	
]

{ #category : #accessing }
BtUDPScrapeRequest >> infoHashCollection [
	^ infoHashCollection
]

{ #category : #accessing }
BtUDPScrapeRequest >> infoHashCollection: anObject [
	infoHashCollection := anObject
]

{ #category : #'initialize-release' }
BtUDPScrapeRequest >> initialize [
	super initialize.
	infoHashCollection := OrderedCollection new.
	transaction actionCode: BtUDPTransaction scrapeActionCode .
]
