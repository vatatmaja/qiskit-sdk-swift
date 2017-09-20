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

/*
Node for an OPENQASM file identifier/version statement ("magic number").
children[0] is a floating point number (not a node).
*/

public final class NodeMagic:  Node {

    public let nodeVersion: NodeReal?

    @objc public init(version: Node?) {
        self.nodeVersion = (version as? NodeReal)
    }

    public override var type: NodeType {
        return .N_MAGIC
    }
    
    public override var children: [Node] {
        var _children: [Node] = []
        
        if let version = nodeVersion {
            _children.append(version)
        }
        
        return _children
    }
    
    public override func qasm(_ prec: Int) -> String {
        guard let version = nodeVersion else {
            assertionFailure("Invalid NodeMagic Operation")
            return ""
        }
        return "OPENQASM \(version.value.format(1));"
    }

}
