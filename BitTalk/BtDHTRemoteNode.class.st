"
A BtDHTRemoteNode is xxxxxxxxx.

"
Class {
	#name : #BtDHTRemoteNode,
	#superclass : #BtDHTNode,
	#instVars : [
		'lastRespondedQueryTime',
		'lastReceivedQueryTime'
	],
	#category : #'BitTalk-DHT'
}

{ #category : #'instance creation' }
BtDHTRemoteNode class >> address: anIntegerAddress port: anIntegerPort [
	| node |
	node:= self new. 
	node domain address: anIntegerAddress.
	node port: anIntegerPort .
	^ node 
]

{ #category : #'instance creation' }
BtDHTRemoteNode class >> id: aNodeID [
	^ self new id: aNodeID
]

{ #category : #'initialize-release' }
BtDHTRemoteNode >> initialize [
	super initialize.
	lastRespondedQueryTime := nil .
	lastReceivedQueryTime := nil .
]

{ #category : #testing }
BtDHTRemoteNode >> isGood [
	"BEP5: A good node is a node has responded to one of our queries within the last 15 minutes. A node is also good if it has ever responded to one of our queries and has sent us a query within the last 15 minutes. After 15 minutes of inactivity, a node becomes questionable."

	^ lastRespondedQueryTime
		ifNotNil: [ 
			(Time millisecondsSince: lastRespondedQueryTime) <= BtDHTLocalNode maxInactivityPeriod
				or: [ 
					lastReceivedQueryTime
						ifNotNil: [ (Time millisecondsSince: lastReceivedQueryTime) <= BtDHTLocalNode maxInactivityPeriod ]
						ifNil: [ false ] ] ]
		ifNil: [ false ]
]

{ #category : #testing }
BtDHTRemoteNode >> isQuestionable [
	^ self isGood not
]

{ #category : #'private - accessing' }
BtDHTRemoteNode >> lastReceivedQueryTime: anObject [
	lastReceivedQueryTime := anObject
]

{ #category : #'private - accessing' }
BtDHTRemoteNode >> lastRespondedQueryTime: anObject [
	lastRespondedQueryTime := anObject
]

{ #category : #accessing }
BtDHTRemoteNode >> lastSeenTime [
	^ lastReceivedQueryTime
		ifNil: [ lastRespondedQueryTime ]
		ifNotNil: [ lastRespondedQueryTime ifNil: [ lastReceivedQueryTime ] ifNotNil: [ lastReceivedQueryTime max: lastRespondedQueryTime ] ]
]

{ #category : #comparing }
BtDHTRemoteNode >> lessOrEqualRecentlySeenThan: anotherBtDHTRemoteNode [
	^ self isQuestionable
		ifTrue: [ 
			anotherBtDHTRemoteNode isGood
				ifTrue: [ true ]
				ifFalse: [ 
					self lastSeenTime
						ifNil: [ true ]
						ifNotNil: [ 
							anotherBtDHTRemoteNode lastSeenTime
								ifNil: [ false ]
								ifNotNil: [ self lastSeenTime <= anotherBtDHTRemoteNode lastSeenTime ] ] ] ]
		ifFalse: [ 
			anotherBtDHTRemoteNode isGood
				ifTrue: [ self lastSeenTime <= anotherBtDHTRemoteNode lastSeenTime ]
				ifFalse: [ false ] ]
]
