# PowerShell script to move files to modular structure

Write-Host "Moving files to modular structure..." -ForegroundColor Green

# Move Authentication Module files
Write-Host "`n=== Authentication Module ===" -ForegroundColor Yellow
Copy-Item "lib\models\user_profile_auth.dart" -Destination "lib\modules\authentication\models\" -Force
Copy-Item "lib\screens\auth_entry_screen.dart" -Destination "lib\modules\authentication\screens\" -Force
Copy-Item "lib\screens\email_input_screen.dart" -Destination "lib\modules\authentication\screens\" -Force
Copy-Item "lib\screens\otp_verify_screen.dart" -Destination "lib\modules\authentication\screens\" -Force
Copy-Item "lib\screens\signup_details_screen.dart" -Destination "lib\modules\authentication\screens\" -Force
Copy-Item "lib\screens\assistant_enrichment_screen.dart" -Destination "lib\modules\authentication\screens\" -Force
Copy-Item "lib\screens\simple_login_screen.dart" -Destination "lib\modules\authentication\screens\" -Force
Copy-Item "lib\screens\simple_signup_screen.dart" -Destination "lib\modules\authentication\screens\" -Force
Copy-Item "lib\services\auth_service.dart" -Destination "lib\modules\authentication\services\" -Force
Write-Host "Authentication module files moved" -ForegroundColor Green

# Move AI Assistant Module files
Write-Host "`n=== AI Assistant Module ===" -ForegroundColor Yellow
Copy-Item "lib\models\assistant_activity.dart" -Destination "lib\modules\ai_assistant\models\" -Force
Copy-Item "lib\models\assistant_alert.dart" -Destination "lib\modules\ai_assistant\models\" -Force
Copy-Item "lib\models\chat_message.dart" -Destination "lib\modules\ai_assistant\models\" -Force
Copy-Item "lib\screens\assistant_screen.dart" -Destination "lib\modules\ai_assistant\screens\" -Force
Copy-Item "lib\screens\assistant_chat_screen.dart" -Destination "lib\modules\ai_assistant\screens\" -Force
Copy-Item "lib\screens\assistant_conversation_screen.dart" -Destination "lib\modules\ai_assistant\screens\" -Force
Copy-Item "lib\screens\attention_alerts_screen.dart" -Destination "lib\modules\ai_assistant\screens\" -Force
Copy-Item "lib\services\ai_profile_service.dart" -Destination "lib\modules\ai_assistant\services\" -Force
Copy-Item "lib\widgets\assistant_activity_list.dart" -Destination "lib\modules\ai_assistant\widgets\" -Force
Copy-Item "lib\widgets\assistant_snapshot.dart" -Destination "lib\modules\ai_assistant\widgets\" -Force
Copy-Item "lib\widgets\chat_log_view.dart" -Destination "lib\modules\ai_assistant\widgets\" -Force
Copy-Item "lib\widgets\conversation_summary_card.dart" -Destination "lib\modules\ai_assistant\widgets\" -Force
Write-Host "AI Assistant module files moved" -ForegroundColor Green

# Move Events Module files
Write-Host "`n=== Events Module ===" -ForegroundColor Yellow
Copy-Item "lib\models\event.dart" -Destination "lib\modules\events\models\" -Force
Copy-Item "lib\screens\event_list_screen.dart" -Destination "lib\modules\events\screens\" -Force
Copy-Item "lib\screens\event_details_screen.dart" -Destination "lib\modules\events\screens\" -Force
Copy-Item "lib\screens\event_assistant_screen.dart" -Destination "lib\modules\events\screens\" -Force
Write-Host "Events module files moved" -ForegroundColor Green

# Move Networking Module files
Write-Host "`n=== Networking Module ===" -ForegroundColor Yellow
Copy-Item "lib\models\qr_profile.dart" -Destination "lib\modules\networking\models\" -Force
Copy-Item "lib\models\network_code.dart" -Destination "lib\modules\networking\models\" -Force
Copy-Item "lib\screens\create_qr_profile_screen.dart" -Destination "lib\modules\networking\screens\" -Force
Copy-Item "lib\screens\create_network_code_screen.dart" -Destination "lib\modules\networking\screens\" -Force
Copy-Item "lib\widgets\qr_card.dart" -Destination "lib\modules\networking\widgets\" -Force
Copy-Item "lib\widgets\qr_scanner_view.dart" -Destination "lib\modules\networking\widgets\" -Force
Copy-Item "lib\widgets\qr_profile_selector_sheet.dart" -Destination "lib\modules\networking\widgets\" -Force
Copy-Item "lib\widgets\network_code_card.dart" -Destination "lib\modules\networking\widgets\" -Force
Copy-Item "lib\widgets\network_code_selector_sheet.dart" -Destination "lib\modules\networking\widgets\" -Force
Copy-Item "lib\widgets\networking_mode_view.dart" -Destination "lib\modules\networking\widgets\" -Force
Copy-Item "lib\widgets\networking_mode_view_new.dart" -Destination "lib\modules\networking\widgets\" -Force
Copy-Item "lib\widgets\scan_result_bottom_sheet.dart" -Destination "lib\modules\networking\widgets\" -Force
Write-Host "Networking module files moved" -ForegroundColor Green

# Move Profile Module files
Write-Host "`n=== Profile Module ===" -ForegroundColor Yellow
Copy-Item "lib\models\user.dart" -Destination "lib\modules\profile\models\" -Force
Copy-Item "lib\models\user_profile.dart" -Destination "lib\modules\profile\models\" -Force
Copy-Item "lib\models\profile_model.dart" -Destination "lib\modules\profile\models\" -Force
Copy-Item "lib\screens\ai_profile_screen.dart" -Destination "lib\modules\profile\screens\" -Force
Copy-Item "lib\screens\edit_profile_screen.dart" -Destination "lib\modules\profile\screens\" -Force
Copy-Item "lib\screens\profile_viewer_screen.dart" -Destination "lib\modules\profile\screens\" -Force
Copy-Item "lib\screens\profile_screen_backup.dart" -Destination "lib\modules\profile\screens\" -Force
Copy-Item "lib\services\profile_repository.dart" -Destination "lib\modules\profile\services\" -Force
Copy-Item "lib\services\documents_service.dart" -Destination "lib\modules\profile\services\" -Force
Copy-Item "lib\widgets\profile_header.dart" -Destination "lib\modules\profile\widgets\" -Force
Copy-Item "lib\widgets\profile_section_card.dart" -Destination "lib\modules\profile\widgets\" -Force
Write-Host "Profile module files moved" -ForegroundColor Green

# Move Goals Module files
Write-Host "`n=== Goals Module ===" -ForegroundColor Yellow
Copy-Item "lib\models\goal.dart" -Destination "lib\modules\goals\models\" -Force
Copy-Item "lib\models\goal_insights.dart" -Destination "lib\modules\goals\models\" -Force
Copy-Item "lib\screens\dashboard_screen.dart" -Destination "lib\modules\goals\screens\" -Force
Copy-Item "lib\screens\create_goal_screen.dart" -Destination "lib\modules\goals\screens\" -Force
Copy-Item "lib\screens\goal_insights_screen.dart" -Destination "lib\modules\goals\screens\" -Force
Copy-Item "lib\services\goals_service.dart" -Destination "lib\modules\goals\services\" -Force
Copy-Item "lib\services\task_execution_service.dart" -Destination "lib\modules\goals\services\" -Force
Copy-Item "lib\widgets\goal_card.dart" -Destination "lib\modules\goals\widgets\" -Force
Copy-Item "lib\widgets\activity_stats_card.dart" -Destination "lib\modules\goals\widgets\" -Force
Copy-Item "lib\widgets\summary_highlight_card.dart" -Destination "lib\modules\goals\widgets\" -Force
Write-Host "Goals module files moved" -ForegroundColor Green

# Move Connections Module files
Write-Host "`n=== Connections Module ===" -ForegroundColor Yellow
Copy-Item "lib\models\connection.dart" -Destination "lib\modules\connections\models\" -Force
Copy-Item "lib\models\my_spaces.dart" -Destination "lib\modules\connections\models\" -Force
Copy-Item "lib\models\following.dart" -Destination "lib\modules\connections\models\" -Force
Copy-Item "lib\models\recommendation.dart" -Destination "lib\modules\connections\models\" -Force
Copy-Item "lib\models\tagged_person.dart" -Destination "lib\modules\connections\models\" -Force
Copy-Item "lib\screens\connections_list_screen.dart" -Destination "lib\modules\connections\screens\" -Force
Copy-Item "lib\screens\my_spaces_screen.dart" -Destination "lib\modules\connections\screens\" -Force
Copy-Item "lib\screens\following_list_screen.dart" -Destination "lib\modules\connections\screens\" -Force
Copy-Item "lib\screens\followers_list_screen.dart" -Destination "lib\modules\connections\screens\" -Force
Copy-Item "lib\screens\recommendations_screen.dart" -Destination "lib\modules\connections\screens\" -Force
Copy-Item "lib\widgets\recommendation_card.dart" -Destination "lib\modules\connections\widgets\" -Force
Copy-Item "lib\widgets\smart_recommendations_section.dart" -Destination "lib\modules\connections\widgets\" -Force
Copy-Item "lib\widgets\match_insight_tile.dart" -Destination "lib\modules\connections\widgets\" -Force
Copy-Item "lib\widgets\match_insight_list_view.dart" -Destination "lib\modules\connections\widgets\" -Force
Copy-Item "lib\widgets\match_category_section.dart" -Destination "lib\modules\connections\widgets\" -Force
Copy-Item "lib\widgets\key_feedback_section.dart" -Destination "lib\modules\connections\widgets\" -Force
Write-Host "Connections module files moved" -ForegroundColor Green

# Move Shared files
Write-Host "`n=== Shared Files ===" -ForegroundColor Yellow
Copy-Item "lib\models\insights_model.dart" -Destination "lib\shared\models\" -Force
Copy-Item "lib\services\app_state.dart" -Destination "lib\shared\services\" -Force
Copy-Item "lib\services\mock_data_service.dart" -Destination "lib\shared\services\" -Force
Write-Host "Shared files moved" -ForegroundColor Green

Write-Host "`n=== File Migration Complete ===" -ForegroundColor Green
Write-Host "All files have been copied to their respective modules" -ForegroundColor Green
Write-Host "Original files remain in place for now" -ForegroundColor Yellow
