{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    const loading = document.getElementById('flutter_loading');
    if (loading && loading.parentNode) {
      loading.parentNode.removeChild(loading);
    }
    await appRunner.runApp();
  },
});
