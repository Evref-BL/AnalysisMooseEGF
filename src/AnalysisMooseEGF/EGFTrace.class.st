Class {
	#name : #EGFTrace,
	#superclass : #Object,
	#instVars : [
		'rawStack',
		'traces'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'instance creation' }
EGFTrace class >> newFromRawStack: aString [
	|t|
	t := EGFTrace new rawStack: aString. 
	t computeTrace. 
	^ t. 
]

{ #category : #'as yet unclassified' }
EGFTrace >> initialize [

	rawStack := String new.
	traces := OrderedCollection new
]

{ #category : #accessing }
EGFTrace >> rawStack [

	^ rawStack
]

{ #category : #accessing }
EGFTrace >> rawStack: anObject [

	rawStack := anObject
]

{ #category : #accessing }
EGFTrace >> traces [

	^ traces
]

{ #category : #accessing }
EGFTrace >> traces: anObject [

	traces := anObject
]
