"
A BtProcessBlockTest is a test class for testing the behavior of BtProcessBlock
"
Class {
	#name : #BtExecutableBlockTest,
	#superclass : #TestCase,
	#instVars : [
		'process'
	],
	#category : #'BitTalk-Tests'
}

{ #category : #running }
BtExecutableBlockTest >> setUp [
	process := BtExecutableBlock new block: [ 1000 benchFib ].
]

{ #category : #running }
BtExecutableBlockTest >> tearDown [
	process terminate .
	Smalltalk garbageCollect .
]

{ #category : #'tests-initialize-release' }
BtExecutableBlockTest >> testInitializeProcess [
	process initializeProcess .
	self assert: process isSuspended .
	process initializeProcess .
	self assert: process isSuspended .
	process resume .
	process initializeProcess .
	self assert: process isSuspended .
]

{ #category : #'tests-operations' }
BtExecutableBlockTest >> testResume [
	process resume .
	self assert: process isScheduled .
]

{ #category : #'tests-operations' }
BtExecutableBlockTest >> testTerminate [
	process resume .
	process terminate .
	self assert: process isTerminated .
	process initializeProcess .
	process terminate .
	self assert: process isTerminated .
]
