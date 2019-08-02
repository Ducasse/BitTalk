"
A BtDHTRemoteNodeTest is a test class for testing the behavior of BtDHTRemoteNode
"
Class {
	#name : #BtDHTRemoteNodeTest,
	#superclass : #TestCase,
	#category : #'BitTalk-Tests'
}

{ #category : #running }
BtDHTRemoteNodeTest >> setUp [
	BtDHTLocalNode maxInactivityPeriod: 1000.
]

{ #category : #running }
BtDHTRemoteNodeTest >> tearDown [
	BtDHTLocalNode setDefaultMaxInactivityPeriod .
]

{ #category : #'tests-testing' }
BtDHTRemoteNodeTest >> testIsGood [
	|  node time |
	"lastRespondedQueryTime | lastReceivedQueryTime | isGood?
	nil    | nil   | False
	nil    | <=t | False
	nil    | >t   | False
	<=t | nil    | True
	<=t | <=t | True
	<=t | >t   | True
	>t   | nil    | False
	>t   | <=t | True
	>t   | >t   | False
	"
	node := BtDHTRemoteNode new.
	time := Time millisecondClockValue.
	node lastRespondedQueryTime: nil.
	node lastReceivedQueryTime: nil.
	self deny: node isGood.
	node lastRespondedQueryTime: nil.
	node lastReceivedQueryTime: time.
	self deny: node isGood.
	node lastRespondedQueryTime: nil.
	node lastReceivedQueryTime: 0.
	self deny: node isGood.
	node lastRespondedQueryTime: time.
	node lastReceivedQueryTime: nil.
	self assert: node isGood.
	node lastRespondedQueryTime: time.
	node lastReceivedQueryTime: time.
	self assert: node isGood.
	node lastRespondedQueryTime: time.
	node lastReceivedQueryTime: 0.
	self assert: node isGood.
	node lastRespondedQueryTime: 0.
	node lastReceivedQueryTime: nil.
	self deny: node isGood.
	node lastRespondedQueryTime: 0.
	node lastReceivedQueryTime: time.
	self assert: node isGood.
	node lastRespondedQueryTime: 0.
	node lastReceivedQueryTime: 0.
	self deny: node isGood
]

{ #category : #'tests-comparing' }
BtDHTRemoteNodeTest >> testLessOrEqualRecentlySeenThan [
	| nodeA nodeB time0 time1 |
	"
	A                   | B                   | Ta   | Tb   | A <= B
	Good             | Good             | t     | t+1 | True
	Good             | Good             | t+1 | t     | False
	Good             | Questionable | t     | ---   | False
	Questionable | Good             | ---   | t     | True
	Questionable | Questionable | t     | t+1 | True
	Questionable | Questionable | t+1 | t     | False
	"
	nodeA := BtDHTRemoteNode new.
	nodeB := BtDHTRemoteNode new.
	time0 := Time millisecondClockValue + 1.
	time1 := time0 + 1.
	nodeA
		lastRespondedQueryTime: time0;
		lastReceivedQueryTime: time0.
	nodeB
		lastRespondedQueryTime: time1;
		lastReceivedQueryTime: time1.
	self assert: (nodeA lessOrEqualRecentlySeenThan: nodeB).
	nodeA
		lastRespondedQueryTime: time1;
		lastReceivedQueryTime: time1.
	nodeB
		lastRespondedQueryTime: time0;
		lastReceivedQueryTime: time0.
	self deny: (nodeA lessOrEqualRecentlySeenThan: nodeB).
	nodeA
		lastRespondedQueryTime: time0;
		lastReceivedQueryTime: time0.
	nodeB
		lastRespondedQueryTime: nil;
		lastReceivedQueryTime: nil.
	self deny: (nodeA lessOrEqualRecentlySeenThan: nodeB).
	nodeA
		lastRespondedQueryTime: nil;
		lastReceivedQueryTime: nil.
	nodeB
		lastRespondedQueryTime: time0;
		lastReceivedQueryTime: time0.
	self assert: (nodeA lessOrEqualRecentlySeenThan: nodeB).
	nodeA
		lastRespondedQueryTime: 0;
		lastReceivedQueryTime: 0.
	nodeB
		lastRespondedQueryTime: 1;
		lastReceivedQueryTime: 1.
	self assert: (nodeA lessOrEqualRecentlySeenThan: nodeB).
	nodeA
		lastRespondedQueryTime: 1;
		lastReceivedQueryTime: 1.
	nodeB
		lastRespondedQueryTime: 0;
		lastReceivedQueryTime: 0.
	self deny: (nodeA lessOrEqualRecentlySeenThan: nodeB)
]
