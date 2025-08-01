# oneSafeRevival_iOS

# Tmp fix

If CI fail on release on the apply_patch_if_needed lane it means the patch to remove crashlytics couldn't be applied
To recrete the patch, please follow the next steps
1. Make sure you don't have any diff in the `oneSafe.xcodeproj/project.pbxproj`
2. Remove FirebaseCrashlytics dep from the `Link Binary With Libraries` in the `Build Phases` of the model module
3. Run `./scripts/create_crashlytics_revert_patch.sh`
4. Commit and push the changes 

<img width="888" alt="Capture d’écran, le 2024-11-11 à 13 51 03" src="https://github.com/user-attachments/assets/bac26423-6d84-4510-8a6f-d939bc45dfaa">

(This is needed to remove crashlytics from the production build and while [crashKiOS issue](https://github.com/touchlab/CrashKiOS/issues/69) is still open cf [this PR](https://github.com/LunabeeStudio/oneSafeRevival_iOS/pull/709)) 

