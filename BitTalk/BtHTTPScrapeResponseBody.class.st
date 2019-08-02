"
A BtScrapeResponse is xxxxxxxxx.

"
Class {
	#name : #BtHTTPScrapeResponseBody,
	#superclass : #Dictionary,
	#category : #'BitTalk-HTTPTrackerProtocol'
}

{ #category : #'instance creation' }
BtHTTPScrapeResponseBody class >> from: aDictionary [
	| scrapeResponse |
	scrapeResponse := self new.
	aDictionary associationsDo: [ :association | scrapeResponse add: association ].
	^ scrapeResponse
]

{ #category : #'instance creation' }
BtHTTPScrapeResponseBody class >> new [
	^ super new initialize
]

{ #category : #accessing }
BtHTTPScrapeResponseBody >> failureReason [
	^self at:'failure reason'
]

{ #category : #accessing }
BtHTTPScrapeResponseBody >> failureReason: aString [
	self at:'failure reason' put: aString
]
