"
A BtPieceCounterTest is a test class for testing the behavior of BtPieceCounter
"
Class {
	#name : #BtPieceCounterTest,
	#superclass : #TestCase,
	#category : #'BitTalk-Tests'
}

{ #category : #'tests-comparing' }
BtPieceCounterTest >> testLowerOrEqualThan [
	| pc1 pc2 |
	pc1:= BtPieceCounter index: 0 count: 0.
	pc2:= BtPieceCounter index: 0 count: 0.	
	self assert: (pc1 lowerOrEqualThan: pc2).
	pc1:= BtPieceCounter index: 0 count: 0.
	pc2:= BtPieceCounter index: 1 count: 0.
	self assert: (pc1 lowerOrEqualThan: pc2). 
	pc1:= BtPieceCounter index: 1 count: 0.
	pc2:= BtPieceCounter index: 0 count: 0.
	self deny: (pc1 lowerOrEqualThan: pc2).
]

{ #category : #'tests-comparing' }
BtPieceCounterTest >> testRarestOrEqualThan [
	| pc1 pc2 |
	pc1:= BtPieceCounter index: 0 count: 0.
	pc2:= BtPieceCounter index: 1 count: 0.	
	self assert: (pc1 rarestOrEqualThan: pc2).
	pc1:= BtPieceCounter index: 0 count: 0.
	pc2:= BtPieceCounter index: 1 count: 1.
	self assert: (pc1 rarestOrEqualThan: pc2). 
	pc1:= BtPieceCounter index: 0 count: 1.
	pc2:= BtPieceCounter index: 1 count: 0.
	self deny: (pc1 rarestOrEqualThan: pc2).
		
]
