Class {
	#name : #RSeGFServices,
	#superclass : #Object,
	#instVars : [
		'shapes',
		'canvas',
		'eGFServiceModel'
	],
	#category : #AnalysisMooseEGF
}

{ #category : #'as yet unclassified' }
RSeGFServices >> buildCanvas [
	
	canvas := RSCanvas new. 
	
	
	
	
	^ canvas
	
]

{ #category : #'instance creation' }
RSeGFServices >> model: aEGFServicesModel [

	eGFServiceModel := aEGFServicesModel
]
