Class {
	#name : #EGFServicesModel,
	#superclass : #Object,
	#instVars : [
		'services'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #intialization }
EGFServicesModel class >> initFrom: aDictionnary [

	| sm |
	sm := self new.
	sm services: aDictionnary.
	^ sm 
]

{ #category : #accessing }
EGFServicesModel >> allServices [
	^ services 
]

{ #category : #'as yet unclassified' }
EGFServicesModel >> computeServicesDependencies [

	| dep index max |
	dep := Set new.
	index := 1.
	max := services associations size.

	services associations from: 1 to: max do: [ :a1 | 
		| model1 |
		model1 := a1 value.
		index := index + 1.
		services associations from: index to: max do: [ :a2 | 
			| model2 |
			model2 := a2 value.
			self haltIf: index > 100.
			((model1 = model2) not and: [ model1 hasCommonMethodsWithModel: model2 ]) 
				ifTrue: [ dep add: model1 -> model2 ] ] ].

	^ dep
]

{ #category : #initialization }
EGFServicesModel >> initialize [ 
	services := Dictionary new. 
]

{ #category : #accessing }
EGFServicesModel >> services [

	^ services
]

{ #category : #accessing }
EGFServicesModel >> services: anObject [

	services := anObject
]
