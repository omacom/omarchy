// Loaded ONLY in our sandboxed FS-UAE, never in the desktop/Pulse server.
// Atomic server creation mute prevents even a single startup audio burst.
#define _GNU_SOURCE
#include <pulse/pulseaudio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <stdio.h>
int pa_stream_connect_playback(pa_stream *s,const char *dev,const pa_buffer_attr *attr,
                              pa_stream_flags_t flags,const pa_cvolume *volume,pa_stream *sync) {
    typedef int (*connect_fn)(pa_stream*,const char*,const pa_buffer_attr*,pa_stream_flags_t,const pa_cvolume*,pa_stream*);
    connect_fn original=(connect_fn)dlsym(RTLD_NEXT,"pa_stream_connect_playback");
    const pa_sample_spec *spec=pa_stream_get_sample_spec(s);
    if (!original || !spec) return -1; // fail closed, no fallback unmuted connect
    pa_cvolume safe;
    pa_cvolume_set(&safe,spec->channels,pa_sw_volume_from_linear(0.10));
    flags=(flags & ~PA_STREAM_START_UNMUTED) | PA_STREAM_START_MUTED;
    fprintf(stderr,"AMIGA_AUDIO atomic-start-muted linear-gain=10%% channels=%u\n",spec->channels);
    return original(s,dev,attr,flags,&safe,sync);
}
