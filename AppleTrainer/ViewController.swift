//
//  ViewController.swift
//  AppleTrainer
//
//  Created by 张轩诚 on 2024/4/11.
//

import UIKit
import CoreML


class ViewController: UIViewController {

    
    @IBOutlet var graphView: GraphView!
    
    var model: MLModel!
    var trainingDataset: ImageDataset!
    var validationDataset: ImageDataset!
    var trainer: NeuralNetworkTrainer!
    let labels = Labels()
    
//    let trainingDataset = ImageDataset(split: .train)
//    let validationDataset = ImageDataset(split: .test)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        trainingDataset = ImageDataset(split: .train)
        validationDataset = ImageDataset(split: .test)
        
        trainingDataset.copyBuiltInImages()
        testingDataset.copyBuiltInImages()
        
        Models.copyEmptyNeuralNetwork()
//        model = Models.loadEmptyNeuralNetwork()
        model = Models.loadTrainedNeuralNetwork()
        
    }


    @IBAction func didTapButtion(_ sender: Any) {
//        trainingDataset.copyBuiltInImages()
//        testingDataset.copyBuiltInImages()
        
        trainer = NeuralNetworkTrainer(modelURL: Models.trainedNeuralNetworkURL,
                                       trainingDataset: trainingDataset,
                                       validationDataset: validationDataset,
                                       imageConstraint: imageConstraint(model: model!))
        trainer.train(epochs: 50, learningRate: 0.001, callback: trainingCallback)
    }
    
    func trainingCallback(callback: NeuralNetworkTrainer.Callback) {
        DispatchQueue.main.async {
            switch callback {
            case let .epochEnd(trainLoss, valLoss, valAcc):
                history.addEvent(trainLoss: trainLoss, validationLoss: valLoss, validationAccuracy: valAcc)
                
                //
//                let indexPath = IndexPath(row: history.count - 1, section: 0)
//                self.tableView.insertRows(at: [indexPath], with: .fade)
//                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                self.graphView.update()
                //
            case .completed(let updatedModel):
//                self.trainingStopped()
                //
                //          // Replace our model with the newly trained one.
                self.model = updatedModel
                //
            case .error:
//                self.trainingStopped()
                print(1)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      graphView.update()
    }
    
}

