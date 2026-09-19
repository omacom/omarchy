// Qt public native interface: same connection and pointer as the guard.
// No global input device, absolute-position heuristic, or idle-resume grace.
#include <QGuiApplication>
#include <QtGui/qguiapplication_platform.h>
#include <QQmlExtensionPlugin>
#include <qqml.h>
#include <QTimer>
#include <QMouseEvent>
#include <QWheelEvent>
#include <wayland-client.h>
#include "relative-pointer.h"
#include <cstring>

class RelativeMotion : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
public:
    explicit RelativeMotion(QObject *parent=nullptr): QObject(parent) {
        native=qGuiApp->nativeInterface<QNativeInterface::QWaylandApplication>();
        qGuiApp->installEventFilter(this);
        if (!native) return; // unsupported/offscreen: fail closed at begin()
        registry=wl_display_get_registry(native->display());
        static const wl_registry_listener listener={global, removed};
        wl_registry_add_listener(registry,&listener,this);
        connect(&retry,&QTimer::timeout,this,&RelativeMotion::attach);
        retry.start(100);
        wl_display_flush(native->display());
    }
    ~RelativeMotion() override {
        if (relative) zwp_relative_pointer_v1_destroy(relative);
        if (manager) zwp_relative_pointer_manager_v1_destroy(manager);
        if (registry) wl_registry_destroy(registry);
    }
    bool ready() const { return relative; }
signals:
    void readyChanged();
    void motion(double dx, double dy);
    void button();
    void wheel();
protected:
    bool eventFilter(QObject *object, QEvent *event) override {
        // Hyprland can focus an exclusive layer on another output, yielding
        // negative local pointer coordinates. Observe classified Qt events
        // before QML hit-testing drops them outside the MouseArea rectangle.
        // This application owns only our guard surfaces; never monitors host apps.
        if (event->type()==QEvent::MouseButtonPress) emit button();
        if (event->type()==QEvent::Wheel) {
            auto e=static_cast<QWheelEvent*>(event);
            if (!e->angleDelta().isNull() || !e->pixelDelta().isNull()) emit wheel();
        }
        return QObject::eventFilter(object,event);
    }
private:
    QNativeInterface::QWaylandApplication *native=nullptr;
    wl_registry *registry=nullptr;
    zwp_relative_pointer_manager_v1 *manager=nullptr;
    zwp_relative_pointer_v1 *relative=nullptr;
    wl_pointer *pointer=nullptr;
    uint32_t managerName=0;
    QTimer retry;
    static void global(void *data,wl_registry *registry,uint32_t name,const char *interface,uint32_t) {
        auto self=static_cast<RelativeMotion*>(data);
        if (!strcmp(interface,"zwp_relative_pointer_manager_v1")) {
            self->managerName=name;
            self->manager=static_cast<zwp_relative_pointer_manager_v1*>(wl_registry_bind(registry,name,&zwp_relative_pointer_manager_v1_interface,1));
            self->attach();
        }
    }
    static void removed(void *data,wl_registry *,uint32_t name) {
        auto self=static_cast<RelativeMotion*>(data);
        if (name!=self->managerName) return;
        if(self->relative) zwp_relative_pointer_v1_destroy(self->relative);
        self->relative=nullptr;
        if(self->manager) zwp_relative_pointer_manager_v1_destroy(self->manager);
        self->manager=nullptr;
        emit self->readyChanged();
    }
    static void moved(void *data,zwp_relative_pointer_v1 *,uint32_t,uint32_t,wl_fixed_t dx,wl_fixed_t dy,wl_fixed_t ux,wl_fixed_t uy) {
        // Unaccelerated delta also catches motion rounded to zero by acceleration.
        if (dx || dy || ux || uy) emit static_cast<RelativeMotion*>(data)->motion(wl_fixed_to_double(ux ? ux : dx),wl_fixed_to_double(uy ? uy : dy));
    }
    void attach() {
        if (!native || !manager) return;
        auto current=native->pointer();
        if (relative && current==pointer) return;
        if (relative) zwp_relative_pointer_v1_destroy(relative);
        relative=nullptr; pointer=current;
        if (pointer) {
            relative=zwp_relative_pointer_manager_v1_get_relative_pointer(manager,pointer);
            static const zwp_relative_pointer_v1_listener listener={moved};
            zwp_relative_pointer_v1_add_listener(relative,&listener,this);
        }
        emit readyChanged();
        wl_display_flush(native->display());
    }
};
class AmigaInputPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID QQmlExtensionInterface_iid)
public:
    void registerTypes(const char *uri) override { qmlRegisterType<RelativeMotion>(uri,1,0,"RelativeMotion"); }
};
#include "plugin.moc"
