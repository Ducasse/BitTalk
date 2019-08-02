"
A BtUDPScrapeTorrentStat is xxxxxxxxx.

Instance Variables
	completed:		<Object>
	leechers:		<Object>
	seeders:		<Object>

completed
	- xxxxx

leechers
	- xxxxx

seeders
	- xxxxx

"
Class {
	#name : #BtUDPScrapeTorrentStat,
	#superclass : #Object,
	#instVars : [
		'completed',
		'leechers',
		'seeders'
	],
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #'converting-arrays' }
BtUDPScrapeTorrentStat >> asByteArray [
	^(seeders asByteArrayOfSize: 4) , 
	(completed asByteArrayOfSize: 4) , 
	(leechers asByteArrayOfSize: 4)
]

{ #category : #accessing }
BtUDPScrapeTorrentStat >> completed [
	^ completed
]

{ #category : #accessing }
BtUDPScrapeTorrentStat >> completed: anObject [
	completed := anObject
]

{ #category : #'initialize-release' }
BtUDPScrapeTorrentStat >> initialize [
	super initialize.
	completed := 0.
	leechers := 0.
	seeders := 0
]

{ #category : #accessing }
BtUDPScrapeTorrentStat >> leechers [
	^ leechers
]

{ #category : #accessing }
BtUDPScrapeTorrentStat >> leechers: anObject [
	leechers := anObject
]

{ #category : #accessing }
BtUDPScrapeTorrentStat >> seeders [
	^ seeders
]

{ #category : #accessing }
BtUDPScrapeTorrentStat >> seeders: anObject [
	seeders := anObject
]
