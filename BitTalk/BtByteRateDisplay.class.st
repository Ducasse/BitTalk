"
A BtByteRateDisplay is xxxxxxxxx.

"
Class {
	#name : #BtByteRateDisplay,
	#superclass : #Object,
	#instVars : [
		'timeUnitSymbol',
		'byteDisplay'
	],
	#classVars : [
		'DaySymbol',
		'HourSymbol',
		'MinuteSymbol',
		'MonthSymbol',
		'SecondSymbol',
		'WeekSymbol',
		'YearSymbol'
	],
	#category : #BitTalk
}

{ #category : #'initialize-release' }
BtByteRateDisplay class >> initialize [
	super initialize.
	SecondSymbol := 's'.
	MinuteSymbol := 'min'.
	HourSymbol := 'h'.
	DaySymbol := 'd'.
	WeekSymbol := 'w'.
	MonthSymbol := 'm'.
	YearSymbol := 'y'.
]

{ #category : #comparing }
BtByteRateDisplay >> >= anotherByteRateDisplay [
	^ self byteDisplay >= anotherByteRateDisplay byteDisplay
]

{ #category : #'as yet unclassified' }
BtByteRateDisplay >> byteDisplay [
	^ byteDisplay
]

{ #category : #'initialize-release' }
BtByteRateDisplay >> initialize [
	super initialize.
	byteDisplay := BtByteDisplay new.
	timeUnitSymbol := SecondSymbol
]

{ #category : #printing }
BtByteRateDisplay >> printOn: aStream [
	| stringStream |
	stringStream := WriteStream with: String new.
	stringStream
		nextPutAll: byteDisplay asString;
		nextPutAll: '/';
		nextPutAll: timeUnitSymbol .
	aStream nextPutAll: stringStream contents
]

{ #category : #accessing }
BtByteRateDisplay >> setDayAsTimeUnit [
	timeUnitSymbol := DaySymbol .
]

{ #category : #accessing }
BtByteRateDisplay >> setHourAsTimeUnit [
	timeUnitSymbol := HourSymbol .
]

{ #category : #accessing }
BtByteRateDisplay >> setMinuteAsTimeUnit [
	timeUnitSymbol := MinuteSymbol .
]

{ #category : #accessing }
BtByteRateDisplay >> setMonthAsTimeUnit [
	timeUnitSymbol := MonthSymbol .
]

{ #category : #accessing }
BtByteRateDisplay >> setSecondAsTimeUnit [
	timeUnitSymbol := SecondSymbol .
]

{ #category : #accessing }
BtByteRateDisplay >> setWeekAsTimeUnit [
	timeUnitSymbol := WeekSymbol .
]

{ #category : #accessing }
BtByteRateDisplay >> setYearAsTimeUnit [
	timeUnitSymbol := YearSymbol .
]
