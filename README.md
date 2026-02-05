Newton's Workshop - Starter scripts for Unity

Overview
- This workspace contains core C# scripts to start a 2D educational sandbox called "Newton's Workshop".

Files added
- Assets/Scripts/LevelObject.cs - base class and save-data types
- Assets/Scripts/SimpleBlock.cs - simple block object
- Assets/Scripts/BouncySpring.cs - spring that applies force on collision
- Assets/Scripts/GoalTarget.cs - trigger-based goal object
- Assets/Scripts/GameManager.cs - handles Edit/Play mode switching
- Assets/Scripts/DragDropManager.cs - drag & drop from toolbox + grid snapping
- Assets/Scripts/SaveLoadManager.cs - JsonUtility-based save/load

Quick usage
1. Create a Unity 2D project and copy the `Assets` folder into your project.
2. Create prefabs for each object type (attach appropriate Collider2D / Rigidbody2D) and assign the prefab references on `DragDropManager` and `SaveLoadManager`.
3. Hook a `GameManager` GameObject in the scene, and optionally a `worldParent` Transform to group placed objects.
4. Use `SaveLoadManager.SaveToJson()` or `SaveToFile()` to persist levels. Use `LoadFromJson()` or `LoadFromFile()` to reconstruct levels.

Notes
- `LevelObjectSaveData.extraFloat` is used by `BouncySpring` to persist `springForce`.
- You may extend `LevelObjectSaveData` to include more custom properties for other object types.

Next steps I can do for you
- Create example prefabs and a sample scene.
- Add a simple UI (toolbox buttons) that calls `DragDropManager.StartDrag("TypeName")`.
- Add runtime preview visuals and snapping options.
