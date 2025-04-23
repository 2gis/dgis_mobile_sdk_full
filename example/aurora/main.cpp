#include <flutter/flutter_aurora.h>
#include <flutter/flutter_compatibility_qt.h>
#include "generated_plugin_registrant.h"

#include <QCoreApplication>

int main(int argc, char * argv[])
{
	aurora::Initialize(argc, argv);
	aurora::EnableQtCompatibility();
	// Нужно обязательно установить для успешной проверки ключа
	QCoreApplication::setOrganizationDomain("ru.mobile.sdk.app");
	aurora::RegisterPlugins();
	aurora::Launch();
	return 0;
}