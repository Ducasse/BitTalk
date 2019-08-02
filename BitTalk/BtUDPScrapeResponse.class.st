"
A BtUDPScrapeResponsePacket is xxxxxxxxx.

"
Class {
	#name : #BtUDPScrapeResponse,
	#superclass : #BtUDPPacket,
	#instVars : [
		'scrapeTorrentStatCollection'
	],
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #comparing }
BtUDPScrapeResponse >> = anotherPacket [
	^ super = anotherPacket
		ifTrue: [ true ]
		ifFalse: [ scrapeTorrentStatCollection = anotherPacket scrapeTorrentStatCollection ]
]

{ #category : #'converting-arrays' }
BtUDPScrapeResponse >> asByteArray [
	| stream |
	stream:= WriteStream with: ByteArray new.
	stream nextPutAll: super asByteArray . 
	scrapeTorrentStatCollection do: [:x | stream nextPutAll: x asByteArray ].
	^stream contents
]

{ #category : #comparing }
BtUDPScrapeResponse >> hash [
	| stream |
	stream := WriteStream with: ByteArray new.
	stream
		nextPutAll: super hash asByteArray;
		nextPutAll: scrapeTorrentStatCollection hash asByteArray.
	^ stream contents hash
]

{ #category : #'initialize-release' }
BtUDPScrapeResponse >> initialize [
	super initialize.
	scrapeTorrentStatCollection := OrderedCollection new.
	transaction actionCode: BtUDPTransaction scrapeActionCode .
]

{ #category : #accessing }
BtUDPScrapeResponse >> scrapeTorrentStatCollection [
	^ scrapeTorrentStatCollection
]
