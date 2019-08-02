"
A TrackerResponse is xxxxxxxxx.

"
Class {
	#name : #BtHTTPAnnounceResponseBody,
	#superclass : #Dictionary,
	#category : #'BitTalk-HTTPTrackerProtocol'
}

{ #category : #'instance creation' }
BtHTTPAnnounceResponseBody class >> from: aDictionary [
	| announceResponse |
	announceResponse := self new.
	aDictionary associationsDo: [ :association | announceResponse add: association ].
	^ announceResponse
]

{ #category : #'instance creation' }
BtHTTPAnnounceResponseBody class >> new [
	^ super new initialize
]

{ #category : #accessing }
BtHTTPAnnounceResponseBody >> atPeers [
	^ self at: 'peers'
]

{ #category : #accessing }
BtHTTPAnnounceResponseBody >> atTrackerIDIfPresent: ifPresentBlock [
	^ self at: 'tracker id' ifPresent: ifPresentBlock
]

{ #category : #accessing }
BtHTTPAnnounceResponseBody >> failureReason [
	^self at:'failure reason'
]

{ #category : #accessing }
BtHTTPAnnounceResponseBody >> failureReason: aString [
	self at:'failure reason' put: aString
]

{ #category : #accessing }
BtHTTPAnnounceResponseBody >> isFailure [
	^self at:'failure reason' ifPresent:[:v | true] ifAbsent:[false]
]
