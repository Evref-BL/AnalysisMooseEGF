Class {
	#name : #EGFServiceExtractor,
	#superclass : #Object,
	#instVars : [
		'mooseModel',
		'serviceEntities',
		'egfCallFlow'
	],
	#category : #'AnalysisMooseEGF-service-extractor'
}

{ #category : #accessing }
EGFServiceExtractor >> egfCallFlow [

	^ egfCallFlow
]

{ #category : #accessing }
EGFServiceExtractor >> egfCallFlow: aEGFCallflowModel [

	egfCallFlow := aEGFCallflowModel
]

{ #category : #'as yet unclassified' }
EGFServiceExtractor >> entitiesTargetReferences: aMooseEntities [

	^ (aMooseEntities queryAllOutgoing collect: [ :ref | ref target ]) 
		  reject: [ :target | (target isKindOf: FMSlotMultivalueLink) ifTrue: [ 
				target anyOne isStub ] ifFalse: [ target isStub ] ]
]

{ #category : #extraction }
EGFServiceExtractor >> extract [


	serviceEntities := (egfCallFlow classDependencies keys collect: [ :c | 
		                    self entitiesTargetReferences: c ]) asSet.

	^ self
]

{ #category : #accessing }
EGFServiceExtractor >> mooseModel [

	^ mooseModel
]

{ #category : #accessing }
EGFServiceExtractor >> mooseModel: aMooseModel [

	mooseModel := aMooseModel
]

{ #category : #accessing }
EGFServiceExtractor >> serviceEntities [

	^ serviceEntities
]

{ #category : #accessing }
EGFServiceExtractor >> serviceEntities: aCollectionOfMooseEntities [

	serviceEntities := aCollectionOfMooseEntities
]
