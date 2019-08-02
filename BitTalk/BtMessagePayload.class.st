"
A BtMessagePayload is xxxxxxxxx.

"
Class {
	#name : #BtMessagePayload,
	#superclass : #Object,
	#category : #'BitTalk-P2P'
}

{ #category : #'converting-arrays' }
BtMessagePayload >> asByteArray [
	self subclassResponsibility 
]

{ #category : #printing }
BtMessagePayload >> printOn: aStream [
	self subclassResponsibility 
]
