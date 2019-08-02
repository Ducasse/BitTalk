"
A BtBitfieldTest is a test class for testing the behavior of BtBitfield
"
Class {
	#name : #BtBitfieldTest,
	#superclass : #TestCase,
	#category : #'BitTalk-Tests'
}

{ #category : #'tests-accessing' }
BtBitfieldTest >> testAt [
| bitfield |
bitfield:= BtBitfield new: 16 with: #[129 128].

self assert: (bitfield at: 0) = 1.
self assert: (bitfield at: 7) = 1.
self assert: (bitfield at: 8) = 1.
self assert: (bitfield at: 15) = 0. 
]

{ #category : #tests }
BtBitfieldTest >> testBitIndex [

self assert: (BtBitfield bitIndex: 0) = 1.
self assert: (BtBitfield bitIndex: 4) = 5.
self assert: (BtBitfield bitIndex: 7) = 8.
self assert: (BtBitfield bitIndex: 8) = 1.
self assert: (BtBitfield bitIndex: 10) = 3.
]

{ #category : #'tests-private' }
BtBitfieldTest >> testByteAt [
	| bitfield |	
	bitfield:= BtBitfield new: 8*3.
	bitfield set: 0.
	self assert: (bitfield byteAt: 1) = 128.
	bitfield set: 8.
	self assert: (bitfield byteAt: 2) = 128.
	bitfield set: 16.
	self assert: (bitfield byteAt: 3) = 128.
	
]

{ #category : #tests }
BtBitfieldTest >> testByteIndex [

self assert: (BtBitfield byteIndex: 0) = 1.
self assert: (BtBitfield byteIndex: 4) = 1.
self assert: (BtBitfield byteIndex: 7) = 1.
self assert: (BtBitfield byteIndex: 8) = 2.
self assert: (BtBitfield byteIndex: 10) = 2.
]

{ #category : #'tests-accessing' }
BtBitfieldTest >> testClear [
	| bitfield |	
	bitfield:= BtBitfield new: 8.
	bitfield clear: 0.
	self assert: (bitfield at: 0) = 0.
	bitfield clear: 0.
	self assert: (bitfield at: 0) = 0.
	bitfield set: 0.
	bitfield clear: 0. 
	self assert: (bitfield at: 0) = 0.
	
]

{ #category : #'tests-accessing' }
BtBitfieldTest >> testInterestingBitfield [
	| b a c d interestingBitfield |
	self should: [ (BtBitfield new: 7) interestingBitfield: (BtBitfield new: 8) ] raise: Error.
	a := BtBitfield new: 8.
	b := BtBitfield new: 8.
	interestingBitfield := a interestingBitfield: b.
	self assert: (interestingBitfield = a and: [ interestingBitfield numBitsSet = 0 ]).
	c := BtBitfield new: 8.
	c set: 0.
	interestingBitfield := a interestingBitfield: c.
	self assert: (interestingBitfield = c and: [ interestingBitfield numBitsSet = 1 ]).
	d := BtBitfield new: 8.
	d set: 0.
	interestingBitfield := c interestingBitfield: a. 
	self assert: (interestingBitfield = a and:[interestingBitfield numBitsSet = 0] ).
	interestingBitfield := c interestingBitfield: d.
	self assert: (interestingBitfield = a and: [ interestingBitfield numBitsSet = 0 ])
]

{ #category : #'tests-accessing' }
BtBitfieldTest >> testIsComplete [
	| bitfield |	
	bitfield:= BtBitfield new: 8.
	0 to: 7 do:[:x | bitfield set: x].
	self assert: bitfield isComplete .
	
	bitfield:= BtBitfield new: 7.
	0 to: 6 do:[:x | bitfield set: x].
	self assert: bitfield isComplete .
	
	bitfield:= BtBitfield new: 7.
	0 to: 5 do:[:x | bitfield set: x].
	self deny: bitfield isComplete .
	
	bitfield:= BtBitfield new: 9.
	0 to: 7 do:[:x | bitfield set: x].
	bitfield set: 8.
	self assert: bitfield isComplete .
	
	bitfield:= BtBitfield new: 9.
	0 to: 7 do:[:x | bitfield set: x].
	self deny: bitfield isComplete .
]

{ #category : #'tests-private' }
BtBitfieldTest >> testModifyValue [
| bitfield |
bitfield:= BtBitfield new: 16.
bitfield modify: 0 value: 1.
self assert: bitfield field = #[128  0].
bitfield modify: 7 value: 1.
self assert: bitfield field = #[129 0].
bitfield modify: 8 value: 1.
self assert: bitfield field = #[129 128].
bitfield modify: 15 value: 1.
self assert: bitfield field = #[129 129].

bitfield modify: 0 value: 0.
self assert: bitfield field = #[1  129].
bitfield modify: 7 value: 0.
self assert: bitfield field = #[0 129].
bitfield modify: 8 value: 0.
self assert: bitfield field = #[0 1].
bitfield modify: 15 value: 0.
self assert: bitfield field = #[0 0].
]

{ #category : #'tests-accessing' }
BtBitfieldTest >> testNumBitsSet [
	| bitfield |	
	bitfield:= BtBitfield new: 8.
	self assert: bitfield numBitsSet = 0.
	bitfield set: 0.
	self assert: bitfield numBitsSet = 1.
	bitfield set: 0.
	self assert: bitfield numBitsSet = 1.
	bitfield clear: 0.
	self assert: bitfield numBitsSet = 0.
	bitfield clear: 0.
	self assert: bitfield numBitsSet = 0.
]

{ #category : #'tests-accessing' }
BtBitfieldTest >> testSet [
	| bitfield |	
	bitfield:= BtBitfield new: 8.
	bitfield set: 0.
	self assert: (bitfield at: 0) = 1.
	bitfield set: 0.
	self assert: (bitfield at: 0) = 1.
	bitfield clear: 0.
	bitfield set: 0. 
	self assert: (bitfield at: 0) = 1.
]
