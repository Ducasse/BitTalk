"
A BtTemporaryPiece is xxxxxxxxx.

"
Class {
	#name : #BtTemporaryPiece,
	#superclass : #Object,
	#instVars : [
		'blocks',
		'blockSize',
		'lastBlockSize',
		'currentSize',
		'requestedArray',
		'numRequested'
	],
	#category : #BitTalk
}

{ #category : #'instance creation' }
BtTemporaryPiece class >> length: length blockSize: blockSize [ 
	| temporaryPiece numBlocks remainder |
	temporaryPiece:= self new.
	numBlocks:=(length / blockSize) ceiling.
	remainder:=length rem: blockSize.
	remainder>0
		ifTrue:[temporaryPiece lastBlockSize: remainder]
		ifFalse:[temporaryPiece lastBlockSize: blockSize ].
	temporaryPiece
		blocks: (Array new: numBlocks) ;
		blockSize: blockSize .	
	^temporaryPiece   
]

{ #category : #operations }
BtTemporaryPiece >> allMissingBlocksAreRequested [
	^ self missingBlocks allSatisfy: [ :offset | self requestedAt: offset]
]

{ #category : #'converting-arrays' }
BtTemporaryPiece >> asByteArray [
	| stream |
	stream:=WriteStream with: ByteArray new. 
	blocks do: [:block | stream nextPutAll: block ].
	^ stream contents 
]

{ #category : #operations }
BtTemporaryPiece >> at: offset [
	self checkOffset: offset.
	^blocks at: (offset / blockSize) + 1 
]

{ #category : #operations }
BtTemporaryPiece >> at: offset put: aByteArray [
	self checkBlock: aByteArray offset: offset.
	(blocks at: (offset / blockSize) + 1)
		ifNil: [currentSize := currentSize + (aByteArray size) ].
	blocks at: (offset / blockSize) + 1 put: aByteArray.
]

{ #category : #accessing }
BtTemporaryPiece >> blockSize: anObject [
	blockSize := anObject
]

{ #category : #operations }
BtTemporaryPiece >> blockSizeOf: offset [
	self checkOffset: offset.
	^self lastBlockOffset = offset
		ifTrue:[lastBlockSize]
		ifFalse:[blockSize]
	
]

{ #category : #accessing }
BtTemporaryPiece >> blocks: aByteArrayCollection [
	blocks := aByteArrayCollection.
	requestedArray size ~= (blocks size) ifTrue: [
		requestedArray := Array new: (blocks size).
		self resetRequestedArray .
	].
]

{ #category : #operations }
BtTemporaryPiece >> checkBlock: aByteArray offset: offset [
	| expectedSize |
	self checkOffset: offset.
	expectedSize:= 
		offset = self lastBlockOffset 
			ifTrue:[lastBlockSize] 
			ifFalse:[blockSize].
	
	aByteArray size ~= expectedSize
		ifTrue:[self error: 'Bad block size']

]

{ #category : #operations }
BtTemporaryPiece >> checkOffset: offset [
	((offset rem: blockSize) ~= 0 or:[offset > self lastBlockOffset ])
		ifTrue:[self error:'Bad block offset'].
]

{ #category : #operations }
BtTemporaryPiece >> clearRequest: offset [
	self checkOffset: offset.
	(requestedArray at: offset / blockSize + 1)
		ifFalse: [ ^ self ].
	numRequested := numRequested - 1.
	requestedArray at: offset / blockSize + 1 put: false
]

{ #category : #accessing }
BtTemporaryPiece >> currentSize [
	^currentSize
]

{ #category : #operations }
BtTemporaryPiece >> deleteBlock: offset [
	self checkOffset: offset.
	(blocks at: (offset / blockSize) + 1)
		ifNotNil: [
			blocks at: (offset / blockSize) + 1 put: nil.
			currentSize := currentSize - (self blockSizeOf: offset) 
		].
	
]

{ #category : #operations }
BtTemporaryPiece >> enumerateAllOffsets [
	^0 to: blockSize*(requestedArray size - 1) by: blockSize
]

{ #category : #accessing }
BtTemporaryPiece >> finalSize [
	^(blockSize * (blocks size - 1)) + lastBlockSize 
]

{ #category : #testing }
BtTemporaryPiece >> hasAnyRequested [
	^ numRequested > 0
]

{ #category : #'initialize-release' }
BtTemporaryPiece >> initialize [
	super initialize.
	blocks := Array new.
	requestedArray := Array new.
	self resetRequestedArray .
	blockSize := 0.
	lastBlockSize := 0.
	currentSize := 0.
]

{ #category : #testing }
BtTemporaryPiece >> isComplete [
	^ self currentSize = (self finalSize)
]

{ #category : #testing }
BtTemporaryPiece >> isHalfway [
	^ currentSize > 0 and:[self isComplete not]
]

{ #category : #operations }
BtTemporaryPiece >> isPresent: offset [ 
	^(self at: offset)
		ifNil: [ false ]
		ifNotNil: [ true ]
]

{ #category : #operations }
BtTemporaryPiece >> lastBlockOffset [
	^blockSize * (blocks size - 1)
]

{ #category : #accessing }
BtTemporaryPiece >> lastBlockSize: anObject [
	lastBlockSize := anObject
]

{ #category : #operations }
BtTemporaryPiece >> missingAndNotRequestedBlocks [
	^self missingBlocks reject: [ :offset| self requestedAt: offset]
]

{ #category : #operations }
BtTemporaryPiece >> missingBlocks [
	^self enumerateAllOffsets reject: [:offset | self isPresent: offset ]
]

{ #category : #accessing }
BtTemporaryPiece >> numRequested [
	^ numRequested
]

{ #category : #operations }
BtTemporaryPiece >> presentBlocks [
	^self enumerateAllOffsets select: [:offset | self isPresent: offset ]
]

{ #category : #operations }
BtTemporaryPiece >> requestedAt: offset [
	self checkOffset: offset.
	^requestedArray at: (offset / blockSize) + 1
]

{ #category : #operations }
BtTemporaryPiece >> requestedBlocks [
	^self enumerateAllOffsets select:[:offset| self requestedAt: offset]
]

{ #category : #operations }
BtTemporaryPiece >> reset [
	blocks := Array new: blocks size.
	requestedArray := Array new: requestedArray size.
	self resetRequestedArray .
	currentSize := 0.
	Smalltalk garbageCollect .
]

{ #category : #operations }
BtTemporaryPiece >> resetRequestedArray [
	1 to: requestedArray size do:[:index| requestedArray at: index put: false].
	numRequested := 0.
]

{ #category : #operations }
BtTemporaryPiece >> setRequest: offset [
	self checkOffset: offset.
	(requestedArray at: offset / blockSize + 1)
		ifTrue: [ ^ self ].
	numRequested := numRequested + 1.
	requestedArray at: offset / blockSize + 1 put: true
]
