"
A BtBlockRequest is xxxxxxxxx.

Instance Variables
	length:		<Object>
	offset:		<Object>
	pieceIndex:		<Object>
	receiverPeer:		<Object>
	requesterPeer:		<Object>

length
	- xxxxx

offset
	- xxxxx

pieceIndex
	- xxxxx

receiverPeer
	- xxxxx

requesterPeer
	- xxxxx

"
Class {
	#name : #BtBlockRequest,
	#superclass : #Object,
	#instVars : [
		'length',
		'offset',
		'pieceIndex'
	],
	#category : #'BitTalk-P2P'
}

{ #category : #'instance creation' }
BtBlockRequest class >> pieceIndex: pieceIndex offset: offset length: length [
	^ BtBlockRequest new pieceIndex: pieceIndex; offset: offset; length: length
]

{ #category : #comparing }
BtBlockRequest >> = anotherBlockRequest [
	^ self == anotherBlockRequest
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherBlockRequest species
				ifTrue: [ pieceIndex = anotherBlockRequest pieceIndex and:[offset = anotherBlockRequest offset and:[length = anotherBlockRequest length] ] ]
				ifFalse: [ false ]
		]
]

{ #category : #'initialize-release' }
BtBlockRequest >> initialize [
	super initialize.
	length := 0.
	offset := 0.
	pieceIndex := 0.
]

{ #category : #accessing }
BtBlockRequest >> length [
	^ length
]

{ #category : #accessing }
BtBlockRequest >> length: anObject [
	length := anObject
]

{ #category : #accessing }
BtBlockRequest >> offset [
	^ offset
]

{ #category : #accessing }
BtBlockRequest >> offset: anObject [
	offset := anObject
]

{ #category : #accessing }
BtBlockRequest >> pieceIndex [
	^ pieceIndex
]

{ #category : #accessing }
BtBlockRequest >> pieceIndex: anObject [
	pieceIndex := anObject
]

{ #category : #printing }
BtBlockRequest >> printOn: aStream [
	aStream 
		nextPutAll: 'Request[Piece: ';
		nextPutAll: pieceIndex asString;
		nextPutAll: ' | Offset: ';
		nextPutAll: offset asString;
		nextPutAll: ' | Length: ';
		nextPutAll: length asString;
		nextPutAll: ']'
]
