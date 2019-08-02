"
A BtBlockPayload is xxxxxxxxx.

"
Class {
	#name : #BtBlockPayload,
	#superclass : #BtMessagePayload,
	#instVars : [
		'begin',
		'block',
		'index'
	],
	#category : #'BitTalk-P2P'
}

{ #category : #comparing }
BtBlockPayload >> = anotherPayload [
	^ self == anotherPayload 
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherPayload species
				ifTrue: [ index = anotherPayload index and:[begin = anotherPayload begin and:[block = anotherPayload block ] ]]
				ifFalse: [ false ] 
		]
]

{ #category : #'converting-arrays' }
BtBlockPayload >> asByteArray [
	| bytes |
			
	bytes:= OrderedCollection new.
	bytes
		addAll: (index asByteArrayOfSize: 4) ;
		addAll: (begin asByteArrayOfSize: 4) ;
		addAll: block . 
		
	^bytes asByteArray
]

{ #category : #accessing }
BtBlockPayload >> begin [
	^ begin
]

{ #category : #accessing }
BtBlockPayload >> begin: anObject [
	begin := anObject
]

{ #category : #accessing }
BtBlockPayload >> block [
	^ block
]

{ #category : #accessing }
BtBlockPayload >> block: anObject [
	block := anObject
]

{ #category : #accessing }
BtBlockPayload >> index [
	^ index
]

{ #category : #accessing }
BtBlockPayload >> index: anObject [
	index := anObject
]

{ #category : #'initialize-release' }
BtBlockPayload >> initialize [
	super initialize.
	begin := 0.
	block := ByteArray new.
	index := 0.
]

{ #category : #printing }
BtBlockPayload >> printOn: aStream [
	aStream
		nextPutAll: index asString;
		nextPutAll: ' ';
		nextPutAll: begin asString;
		nextPutAll: ' ';
		nextPutAll: 'block size->';
		nextPutAll: block size asString
]
