"
Represento un bitfield tal y como está descrito en el Protocolo BitTorrent. Mi función es llevar el control de qué piezas del torrent se tiene y cuales no. El índice de la primera pieza es el 0.

"
Class {
	#name : #BtBitfield,
	#superclass : #Object,
	#instVars : [
		'field',
		'length',
		'numBitsSet'
	],
	#category : #BitTalk
}

{ #category : #indexing }
BtBitfield class >> bitIndex: pieceIndex [
	^ (pieceIndex % 8) + 1
]

{ #category : #indexing }
BtBitfield class >> byteIndex: pieceIndex [
	^ (pieceIndex quo: 8) + 1
]

{ #category : #'instance creation' }
BtBitfield class >> new: anInteger [
	"anInteger is the number of pieces of the torrent"
	^self new: anInteger with: (ByteArray new: (anInteger / 8) ceiling )

]

{ #category : #'instance creation' }
BtBitfield class >> new: anInteger with: aByteArray [
	"anInteger is the number of pieces of the torrent"
	| bitfield |
	anInteger <= ((aByteArray size) * 8)
		ifFalse:[self error:'Bad length'].
	bitfield:= self new.
	bitfield field: (aByteArray copyFrom: 1 to: (anInteger/8) ceiling ) .
	bitfield length: anInteger.
	^bitfield
]

{ #category : #comparing }
BtBitfield >> = anotherBitfield [
	^ self == anotherBitfield
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherBitfield species
				ifTrue: [ 
					length = anotherBitfield length
						ifTrue: [ 
							numBitsSet = anotherBitfield numBitsSet
								ifTrue: [ 
									((1 to: (length quo: 8)) allSatisfy: [ :index | (self byteAt: index) = (anotherBitfield byteAt: index) ])
										and: [ 
											length > 0
												ifFalse: [ true ]
												ifTrue: [ 
													| lastByte anotherLastByte |
													lastByte := self byteAt: (length / 8) ceiling.
													anotherLastByte := self byteAt: (length / 8) ceiling.
													(1 to: (length rem: 8)) allSatisfy: [ :index | (lastByte bitAt: index) = (anotherLastByte bitAt: index) ] ] ] ]
								ifFalse: [ false ] ]
						ifFalse: [ false ] ]
				ifFalse: [ false ] ]
]

{ #category : #testing }
BtBitfield >> anySpareBitSet [
	^ length = (field size * 8)
		ifTrue:[false]
		ifFalse:[
			self enumerateSpareBits anySatisfy: [ :index | 
				|  byteIndex bitIndex |
				byteIndex:= self class byteIndex: index .					
				bitIndex:= self class bitIndex: index .
				((field at: byteIndex) bitAt: 9 - bitIndex) = 1
			]
		]
]

{ #category : #operations }
BtBitfield >> at: pieceIndex [
"Devuelvo el valor del bit en pieceIndex"
	|   bitIndex byte   |
	byte:= self byteAt: pieceIndex .
	bitIndex:= self class bitIndex: pieceIndex .
	^byte bitAt: 9 - bitIndex.
]

{ #category : #operations }
BtBitfield >> bitsClear [
	^ (0 to: length - 1) select: [ :index | (self at: index) = 0 ]
]

{ #category : #operations }
BtBitfield >> bitsSet [
	^ (0 to: length - 1) select: [ :index | (self at: index) = 1 ]
]

{ #category : #private }
BtBitfield >> byteAt: pieceIndex [
	| byteIndex |
	
	(self properIndex: pieceIndex) 
		ifFalse:[BtBitfieldBadIndex signal].
		
	byteIndex:= self class byteIndex: pieceIndex .
	^field at: byteIndex.
]

{ #category : #operations }
BtBitfield >> check [
	numBitsSet:=0.
	0 to: length - 1 do:[ :index | numBitsSet:= numBitsSet + (self at: index)]
]

{ #category : #operations }
BtBitfield >> clear: pieceIndex [
	"Pongo el bit pieceIndex a 0. Devuelve true si el eatdo previo del bit era 1, false en caso contrario"

	^ [ 
	(self at: pieceIndex) = 1
		ifTrue: [ 
			self modify: pieceIndex value: 0.
			numBitsSet := numBitsSet - 1.
			true ]
		ifFalse: [ false ] ]
		on: BtBitfieldBadIndex
		do: [ :ex | ex return: false ]
]

{ #category : #operations }
BtBitfield >> clearAll [
"Pongo todos los bits a 0"
	field := ByteArray new: (length / 8) ceiling .
	numBitsSet:= 0.
]

{ #category : #operations }
BtBitfield >> clearSpareBits [
	self spareBitsDo: [ :index | 
		|  byteIndex bitIndex |
		byteIndex:= self class byteIndex: index .					
		bitIndex:= self class bitIndex: index .
		(field at: byteIndex) bitAt: 9 - bitIndex put: 0.
	].
]

{ #category : #operations }
BtBitfield >> enumerateSpareBits [
	^ length to: (field size * 8) - 1
]

{ #category : #private }
BtBitfield >> field [
	^ field
]

{ #category : #private }
BtBitfield >> field: aByteArray [
	field:= aByteArray.
]

{ #category : #operations }
BtBitfield >> firstBitClear [
	^(0 to: length - 1) detect:[:bit | (self at: bit) = 0 ] ifNone:[nil]
]

{ #category : #'initialize-release' }
BtBitfield >> initialize [
	super initialize.
	numBitsSet:= 0.
	field := ByteArray new.
	length := 0.
]

{ #category : #operations }
BtBitfield >> interestingBitfield: anotherBitfield [
	"Return a new bitfield whose bits are set if and only if self have these bit clear and anotherBitfield have it set"

	| anotherField newField newBitfield interestingHave |
	length ~= anotherBitfield length
		ifTrue: [ BtBitfieldBadLength signal ].
	anotherBitfield clearSpareBits.
	anotherField := anotherBitfield field.
	newField := ByteArray new: field size.
	interestingHave := 0.
	1 to: field size do: [ :index | 
		| anotherByte byte newByte |
		byte := field at: index.
		anotherByte := anotherField at: index.
		newByte := (byte bitXor: anotherByte) bitAnd: anotherByte.
		newField at: index put: newByte.
		(1 to: 8) do: [ :bitPos | interestingHave := interestingHave + (newByte bitAt: bitPos) ] ].
	newBitfield := self class new: length with: newField.
	newBitfield numBitsSet: interestingHave.
	^ newBitfield
]

{ #category : #testing }
BtBitfield >> isComplete [
	^numBitsSet = length
]

{ #category : #accessing }
BtBitfield >> length [
"Devuelvo mi tamaño"
	^ length
]

{ #category : #private }
BtBitfield >> length: anInteger [
	length := anInteger
]

{ #category : #private }
BtBitfield >> modify: pieceIndex value: bit [
	| byteIndex  bitIndex byte newByte |
	
	byte:= self byteAt: pieceIndex .
	bitIndex := self class bitIndex: pieceIndex .
	newByte:= byte bitAt: 9 - bitIndex put: bit.
	byteIndex := self class byteIndex: pieceIndex. 
	field at: byteIndex put: newByte.
]

{ #category : #accessing }
BtBitfield >> numBitsSet [
"Devuelvo el número de bits a 1"
	^ numBitsSet
]

{ #category : #private }
BtBitfield >> numBitsSet: anInteger [
	numBitsSet := anInteger
]

{ #category : #copying }
BtBitfield >> postCopy [
	super postCopy .
	length := length copy.
	numBitsSet := numBitsSet copy.
	field := field copy.
]

{ #category : #printing }
BtBitfield >> printOn: aStream [
	aStream
		nextPutAll: 'Bitfield[';
		nextPutAll: numBitsSet asString;
		nextPutAll: ' of ';
		nextPutAll: length asString;
		nextPutAll: ']'
]

{ #category : #private }
BtBitfield >> properIndex: pieceIndex [
	^pieceIndex + 1 > length
		ifTrue:[false]
		ifFalse:[true]	
]

{ #category : #operations }
BtBitfield >> reduceTo: newLength [
	length > newLength
		ifTrue: [ 
			(newLength to: length - 1) do: [ :index | numBitsSet := numBitsSet - (self at: index) ].
			length := newLength ]
		ifFalse: [ 
			newLength > length
				ifTrue: [ self error: 'newLength >  length' ] ]
]

{ #category : #operations }
BtBitfield >> set: pieceIndex [
	"Pongo el bit pieceIndex a 1. Devuelve true si el estado previo del bit era 0, falso en caso contrario"

	^ [ 
	(self at: pieceIndex) = 0
		ifTrue: [ 
			self modify: pieceIndex value: 1.
			numBitsSet := numBitsSet + 1.
			true ]
		ifFalse: [ false ] ]
		on: BtBitfieldBadIndex
		do: [ :ex | ex return: false ]
]

{ #category : #operations }
BtBitfield >> spareBitsDo: indexBlock [
	self enumerateSpareBits do: indexBlock 
]
