"
A BtBucketTreeTest is a test class for testing the behavior of BtBucketTree
"
Class {
	#name : #BtBucketTreeTest,
	#superclass : #TestCase,
	#instVars : [
		'bucketTree',
		'node0',
		'node1',
		'node3',
		'node4',
		'node7',
		'node6',
		'node5',
		'node2',
		'node8'
	],
	#category : #'BitTalk-Tests'
}

{ #category : #running }
BtBucketTreeTest >> setUp [
	bucketTree := BtBucketTree firstID: 0 lastID: 7 k: 4.
	node0 := BtDHTRemoteNode id: 0.
	node1 := BtDHTRemoteNode id: 1.
	node2 := BtDHTRemoteNode id: 2.
	node3 := BtDHTRemoteNode id: 3.
	node4 := BtDHTRemoteNode id: 4.
	node5 := BtDHTRemoteNode id: 5.
	node6 := BtDHTRemoteNode id: 6.
	node7 := BtDHTRemoteNode id: 7.
	node8 := BtDHTRemoteNode id: 8
]

{ #category : #'tests-operations' }
BtBucketTreeTest >> testCase [
	| left rigth |
	self should: [ bucketTree add: nil ] raise: BtDHTBadClass.
	self should: [ bucketTree split ] raise: BtDHTNotFullBucket.
	self assert: (bucketTree pickNode: 0) isNil .
	self should: [ bucketTree add: node8 ] raise: BtDHTOutOfRange.
	bucketTree add: node7.
	self assert: (bucketTree pickNode: 7) = (BtDHTRemoteNode id: 7).
	self should: [ bucketTree add: node7 ] raise: BtDHTNodeAlreadyExists.
	self should: [ bucketTree split ] raise: BtDHTNotFullBucket.
	bucketTree add: node3.
	self should: [ bucketTree split ] raise: BtDHTNotFullBucket.
	bucketTree add: node4.
	self should: [ bucketTree split ] raise: BtDHTNotFullBucket.
	bucketTree add: node0.
	self should: [ bucketTree add: node1 ] raise: BtDHTFullBucket.
	bucketTree split.
	self should: [ bucketTree add: node1 ] raise: BtDHTBucketIsNotLeaf.
	self should: [ bucketTree add: node6 ] raise: BtDHTBucketIsNotLeaf.
	self
		assert:
			((left := bucketTree bucketForID: node1 id)
				includesAll:
					{node0.
					node3}).
	self should: [ left split ] raise: BtDHTNotFullBucket.
	left
		add: node1;
		add: node2.
	self
		assert:
			((left := bucketTree bucketForID: node1 id)
				includesAll:
					{node0.
					node3.
					node1.
					node2}).
	self should: [ left split ] raise: BtDHTIDSpaceTooSmall.
	self
		assert:
			((rigth := bucketTree bucketForID: node7 id)
				includesAll:
					{node4.
					node7}).
	self should: [ rigth split ] raise: BtDHTNotFullBucket.
	rigth
		add: node5;
		add: node6.
	self
		assert:
			((rigth := bucketTree bucketForID: node7 id)
				includesAll:
					{node4.
					node5.
					node6.
					node7}).
	self should: [ rigth split ] raise: BtDHTIDSpaceTooSmall
]
