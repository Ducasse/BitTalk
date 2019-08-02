"
A BtRPCQueue is xxxxxxxxx.

"
Class {
	#name : #BtRPCQueue,
	#superclass : #SharedQueue,
	#category : #'BitTalk-DHT'
}

{ #category : #accessing }
BtRPCQueue >> nextPut: aBtRPC [
	aBtRPC species ~= BtRPC
		ifTrue: [ self error: 'Bad class' ].
	^ super nextPut: aBtRPC.	
]
