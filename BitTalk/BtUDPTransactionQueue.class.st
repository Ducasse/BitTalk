"
A BtUDPActionQueue is xxxxxxxxx.

"
Class {
	#name : #BtUDPTransactionQueue,
	#superclass : #SharedQueue,
	#category : #'BitTalk-UDPTrackerProtocol'
}

{ #category : #'initialize-release' }
BtUDPTransactionQueue >> initialize [
	super initialize.
	items := SortedCollection sortBlock: [ :a :b | a priorOrEqualTo: b ]
]

{ #category : #accessing }
BtUDPTransactionQueue >> nextPut: aTransaction [
	aTransaction species ~= BtUDPTransaction ifTrue:[self error: 'Bad class'].
	monitor
		critical: [ 
			aTransaction actionCode = BtUDPTransaction announceActionCode
				ifTrue: [ self nextPutAnnounceAction: aTransaction ]
				ifFalse: [ 
					aTransaction actionCode = BtUDPTransaction scrapeActionCode
						ifTrue: [ self nextPutScrapeAction: aTransaction ]
						ifFalse: [ 
							aTransaction actionCode = BtUDPTransaction connectActionCode
								ifTrue: [ self nextPutConnectAction: aTransaction ] ] ].
			monitor signal ].
	^ aTransaction
]

{ #category : #private }
BtUDPTransactionQueue >> nextPutAnnounceAction: aTransaction [
	(items anySatisfy: [ :x | x actionCode = BtUDPTransaction announceActionCode ])
		ifFalse: [ items add: aTransaction ]
]

{ #category : #private }
BtUDPTransactionQueue >> nextPutConnectAction: aTransaction [
	(items anySatisfy: [ :x | x actionCode = BtUDPTransaction connectActionCode ])
		ifFalse: [ items add: aTransaction ]
]

{ #category : #private }
BtUDPTransactionQueue >> nextPutScrapeAction: aTransaction [
	(items anySatisfy: [ :x | x actionCode = BtUDPTransaction scrapeActionCode ])
		ifFalse: [ items add: aTransaction ]
]
