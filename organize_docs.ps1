# PowerShell Script: Organize Documentation Files
# Gom tất cả .md files vào docs/ với số thứ tự

$rootPath = "d:\CODING\QUIZAPP 1.0\quiz_app"
$docsPath = "$rootPath\docs"

# Ensure docs folder exists
if (-not (Test-Path $docsPath)) {
    New-Item -ItemType Directory -Path $docsPath -Force
}

# Define files to move (theo thứ tự ưu tiên)
$filesToMove = @(
    # Quick Start
    @{Old = "README.md"; New = "01_QUICK_START.md"; Priority = 1},
    @{Old = "FEATURE_FIRST_SUMMARY.md"; New = "02_FEATURE_FIRST_SUMMARY.md"; Priority = 2},
    
    # Project Structure
    @{Old = "PROJECT_STRUCTURE.md"; New = "03_PROJECT_STRUCTURE.md"; Priority = 3},
    @{Old = "RESTRUCTURE_COMPLETE.md"; New = "04_RESTRUCTURE_COMPLETE.md"; Priority = 4},
    @{Old = "CLEANUP_GUIDE.md"; New = "05_CLEANUP_GUIDE.md"; Priority = 5},
    
    # Firebase
    @{Old = "FIREBASE_SETUP_NOW.md"; New = "06_FIREBASE_SETUP.md"; Priority = 6},
    @{Old = "docs\FIREBASE_INTEGRATION.md"; New = "07_FIREBASE_INTEGRATION.md"; Priority = 7},
    @{Old = "FIREBASE_CONSOLE_SETUP.md"; New = "08_FIREBASE_CONSOLE_SETUP.md"; Priority = 8},
    @{Old = "FIREBASE_MIGRATION_SUMMARY.md"; New = "09_FIREBASE_MIGRATION.md"; Priority = 9},
    @{Old = "FIRESTORE_SERVICE_DOCS.md"; New = "10_FIRESTORE_SERVICE_DOCS.md"; Priority = 10},
    
    # Firestore Rules
    @{Old = "FIRESTORE_RULES_QUICK.md"; New = "11_FIRESTORE_RULES_QUICK.md"; Priority = 11},
    @{Old = "FIRESTORE_RULES_GUIDE.md"; New = "12_FIRESTORE_RULES_GUIDE.md"; Priority = 12},
    
    # Auth
    @{Old = "docs\AUTH_FLOW.md"; New = "13_AUTH_FLOW.md"; Priority = 13},
    @{Old = "docs\AUTH_REVIEW_SUMMARY.md"; New = "14_AUTH_REVIEW.md"; Priority = 14},
    @{Old = "docs\auth\AUTH_MODULE_README.md"; New = "15_AUTH_MODULE.md"; Priority = 15},
    @{Old = "docs\auth\GOOGLE_SIGNIN_GUIDE.md"; New = "16_GOOGLE_SIGNIN.md"; Priority = 16},
    
    # Fixes
    @{Old = "QUICK_FIX_DONE.md"; New = "17_QUICK_FIXES.md"; Priority = 17},
    @{Old = "docs\FIX_VIETNAMESE_FONT.md"; New = "18_VIETNAMESE_FONT_FIX.md"; Priority = 18},
    
    # Index
    @{Old = "NEW_FILES_INDEX.md"; New = "19_NEW_FILES_INDEX.md"; Priority = 19}
)

Write-Host "🚀 Starting documentation organization..." -ForegroundColor Green

$movedCount = 0
$skippedCount = 0

foreach ($file in $filesToMove) {
    $oldPath = Join-Path $rootPath $file.Old
    $newPath = Join-Path $docsPath $file.New
    
    if (Test-Path $oldPath) {
        try {
            # Copy to new location
            Copy-Item -Path $oldPath -Destination $newPath -Force
            Write-Host "✅ [$($file.Priority)] Moved: $($file.Old) → docs\$($file.New)" -ForegroundColor Cyan
            
            # Delete old file if not already in docs/
            if ($file.Old -notlike "docs\*") {
                Remove-Item -Path $oldPath -Force
                Write-Host "   🗑️  Deleted old: $($file.Old)" -ForegroundColor Yellow
            }
            
            $movedCount++
        } catch {
            Write-Host "❌ Error moving $($file.Old): $_" -ForegroundColor Red
            $skippedCount++
        }
    } else {
        Write-Host "⚠️  [$($file.Priority)] Not found: $($file.Old)" -ForegroundColor Gray
        $skippedCount++
    }
}

Write-Host "`n📊 SUMMARY:" -ForegroundColor Green
Write-Host "   ✅ Moved: $movedCount files" -ForegroundColor Cyan
Write-Host "   ⚠️  Skipped: $skippedCount files" -ForegroundColor Yellow

Write-Host "`n🎉 Documentation organization complete!" -ForegroundColor Green
Write-Host "   📁 All files are now in: $docsPath" -ForegroundColor Cyan
