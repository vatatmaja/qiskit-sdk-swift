// Copyright 2017 IBM RESEARCH. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

import Foundation
import qiskit

/**
 Quantum teleportation example based on an OpenQASM example.
 */
public final class Teleport {

    private static let backend: String = "ibmqx_qasm_simulator"

    private static let QPS_SPECS: [String: Any] = [
            "name": "Program",
            "circuits": [[
                "name": "teleport",
                "quantum_registers": [[
                    "name": "q",
                    "size": 3
            ]],
            "classical_registers": [
                ["name": "c0",
                "size": 1],
                ["name": "c1",
                "size": 1],
                ["name": "c2",
                "size": 1],
            ]]]
    ]
    //##############################################################
    // Set the device name and coupling map.
    //##############################################################
    private static let coupling_map = [0: [1, 2],
        1: [2],
        2: [],
        3: [2, 4],
        4: [2]]

    private init() {
    }

    //##############################################################
    // Make a quantum program for the GHZ and Bell states.
    //##############################################################
   
    public class func teleport(_ apiToken: String, _ responseHandler: ((Void) -> Void)? = nil) {
        do {
            print()
            print("#################################################################")
            print("Teleport:")
            let qConfig = try Qconfig(APItoken: apiToken)
            let qp = try QuantumProgram(specs: QPS_SPECS)
            let qc = try qp.get_circuit("teleport")
            let q = try qp.get_quantum_register("q")
            let c0 = try qp.get_classical_register("c0")
            let c1 = try qp.get_classical_register("c1")
            let c2 = try qp.get_classical_register("c2")

            // Prepare an initial state
            try qc.u3(0.3, 0.2, 0.1, q[0])

            // Prepare a Bell pair
            try qc.h(q[1])
            try qc.cx(q[1], q[2])

            // Barrier following state preparation
            try qc.barrier(q)

            // Measure in the Bell basis
            try qc.cx(q[0], q[1])
            try qc.h(q[0])
            try qc.measure(q[0], c0[0])
            try qc.measure(q[1], c1[0])

            // Apply a correction
            try qc.z(q[2]).c_if(c0, 1)
            try qc.x(q[2]).c_if(c1, 1)
            try qc.measure(q[2], c2[0])

            //##############################################################
            // Set up the API and execute the program.
            //##############################################################
            try qp.set_api(token: qConfig.APItoken, url: qConfig.url.absoluteString)

            print("Experiment does not support feedback, so we use the simulator")

            print("First version: not mapped")
            qp.execute(["teleport"], backend: backend,shots: 1024, coupling_map: nil) { (result,error) in
                do {
                    if error != nil {
                        print(error!.description)
                        responseHandler?()
                        return
                    }
                    print(result)
                    print(try result.get_counts("teleport"))

                    print("Second version: mapped to qx2 coupling graph")
                    qp.execute(["teleport"], backend: backend,shots: 1024, coupling_map: coupling_map) { (result,error) in
                        do {
                            if error != nil {
                                print(error!.description)
                                responseHandler?()
                                return
                            }
                            print(result)
                            print(try result.get_ran_qasm("teleport"))
                            print(try result.get_counts("teleport"))
                            print("Both versions should give the same distribution")
                        } catch {
                            print(error.localizedDescription)
                        }
                        responseHandler?()
                    }
                } catch {
                    print(error.localizedDescription)
                    responseHandler?()
                }
            }
        } catch {
            print(error.localizedDescription)
            responseHandler?()
        }
    }
}