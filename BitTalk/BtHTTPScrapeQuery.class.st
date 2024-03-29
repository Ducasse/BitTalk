"
A BtScrapeRequest is xxxxxxxxx.

"
Class {
	#name : #BtHTTPScrapeQuery,
	#superclass : #Object,
	#instVars : [
		'infoHashCollection'
	],
	#category : #'BitTalk-HTTPTrackerProtocol'
}

{ #category : #accessing }
BtHTTPScrapeQuery >> infoHashCollection [
	^ infoHashCollection
]

{ #category : #accessing }
BtHTTPScrapeQuery >> infoHashCollection: anObject [
	infoHashCollection := anObject
]

{ #category : #'initialize-release' }
BtHTTPScrapeQuery >> initialize [
	super initialize.
	infoHashCollection := OrderedCollection new.
]

{ #category : #printing }
BtHTTPScrapeQuery >> printOn: aStream [
	| queryString percentEncoder |
	percentEncoder := ZnPercentEncoder new.
	percentEncoder characterEncoder: ZnNullEncoder new.
	queryString := WriteStream with: String new.
	infoHashCollection
		withIndexDo: [ :infoHash :index | 
			queryString
				nextPutAll: 'info_hash=';
				nextPutAll: (percentEncoder encode: (infoHash asByteArrayOfSize: 20) asString).
			index = infoHashCollection size
				ifFalse: [ queryString nextPut: $& ] ].
	aStream nextPutAll: queryString contents.
]
