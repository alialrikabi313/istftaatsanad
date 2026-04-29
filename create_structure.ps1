# create_structure.ps1

# إنشاء المجلدات
mkdir lib\core\router, lib\core\theme, lib\core\utils, lib\core\widgets -Force
mkdir lib\features\auth\domain\entities, lib\features\auth\domain\repositories, lib\features\auth\data\datasources, lib\features\auth\data\models, lib\features\auth\data\repositories, lib\features\auth\presentation\pages, lib\features\auth\presentation\providers -Force
mkdir lib\features\content\domain\entities, lib\features\content\domain\repositories, lib\features\content\data\datasources, lib\features\content\data\models, lib\features\content\data\repositories, lib\features\content\presentation\pages, lib\features\content\presentation\providers, lib\features\content\presentation\widgets -Force
mkdir lib\features\inbox\domain\entities, lib\features\inbox\domain\repositories, lib\features\inbox\data\datasources, lib\features\inbox\data\repositories, lib\features\inbox\presentation\providers -Force
mkdir lib\di -Force

# إنشاء الملفات
ni lib\main.dart, lib\bootstrap.dart -Force
ni lib\core\router\app_router.dart, lib\core\theme\app_theme.dart, lib\core\utils\date_time_utils.dart, lib\core\widgets\app_scaffold.dart, lib\core\widgets\async_value_widget.dart, lib\core\widgets\empty_placeholder.dart -Force
ni lib\features\auth\domain\entities\app_user.dart, lib\features\auth\domain\repositories\auth_repository.dart, lib\features\auth\data\datasources\firebase_auth_remote.dart, lib\features\auth\data\repositories\auth_repository_impl.dart, lib\features\auth\presentation\providers\auth_providers.dart, lib\features\auth\presentation\pages\sign_in_page.dart -Force
ni lib\features\content\domain\entities\topic.dart, lib\features\content\domain\entities\subtopic.dart, lib\features\content\domain\entities\qa_item.dart, lib\features\content\domain\repositories\content_repository.dart -Force
ni lib\features\content\data\datasources\firestore_content_remote.dart, lib\features\content\data\models\topic_dto.dart, lib\features\content\data\models\subtopic_dto.dart, lib\features\content\data\models\qa_item_dto.dart, lib\features\content\data\repositories\content_repository_impl.dart -Force
ni lib\features\content\presentation\providers\content_providers.dart, lib\features\content\presentation\pages\home_page.dart, lib\features\content\presentation\pages\subtopics_page.dart, lib\features\content\presentation\pages\questions_page.dart, lib\features\content\presentation\pages\question_detail_page.dart, lib\features\content\presentation\pages\favorites_page.dart, lib\features\content\presentation\pages\search_page.dart -Force
ni lib\features\content\presentation\widgets\topic_card.dart, lib\features\content\presentation\widgets\subtopic_tile.dart, lib\features\content\presentation\widgets\qa_tile.dart, lib\features\content\presentation\widgets\ask_question_sheet.dart -Force
ni lib\features\inbox\domain\entities\user_question.dart, lib\features\inbox\domain\repositories\question_inbox_repository.dart, lib\features\inbox\data\datasources\firestore_inbox_remote.dart, lib\features\inbox\data\repositories\question_inbox_repository_impl.dart, lib\features\inbox\presentation\providers\inbox_providers.dart -Force
ni lib\di\providers.dart -Force
