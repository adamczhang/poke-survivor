// PokeSurvivor web port: Cloudflare Workers static assets cap each file at 25 MiB, so the
// engine (index.wasm) and game data (index.pck) are published as numbered, content-hashed
// chunks. This shim intercepts Godot's fetch of the original file names and streams the
// chunks back in order, so Godot's progress bar keeps moving and the bytes are unchanged.
(() => {
  const manifest = __CHUNK_MANIFEST__;
  const nativeFetch = globalThis.fetch.bind(globalThis);
  const base = document.baseURI;
  const byURL = new Map(Object.entries(manifest).map(([name, info]) => [new URL(name, base).href, info]));
  const PARALLEL = 3;
  const RETRIES = 3;

  async function fetchChunk(url, signal) {
    let lastError;
    for (let attempt = 0; attempt < RETRIES; attempt++) {
      try {
        const response = await nativeFetch(url, { signal, cache: 'default' });
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return new Uint8Array(await response.arrayBuffer());
      } catch (error) {
        if (signal && signal.aborted) throw error;
        lastError = error;
        await new Promise(resolve => setTimeout(resolve, 500 * (attempt + 1)));
      }
    }
    throw new Error(`Download failed: ${url} (${lastError})`);
  }

  function streamChunks(info, signal) {
    const urls = info.chunks.map(name => new URL(name, base).href);
    const inFlight = [];
    let next = 0;
    const startNext = () => {
      if (next < urls.length) inFlight.push(fetchChunk(urls[next++], signal));
    };
    return new ReadableStream({
      start() {
        for (let i = 0; i < PARALLEL; i++) startNext();
      },
      async pull(controller) {
        if (inFlight.length === 0) {
          controller.close();
          return;
        }
        try {
          const bytes = await inFlight.shift();
          startNext();
          controller.enqueue(bytes);
        } catch (error) {
          controller.error(error);
        }
      },
    });
  }

  globalThis.fetch = function (input, init) {
    const url = input instanceof Request ? input.url : new URL(String(input), base).href;
    const info = byURL.get(url);
    if (!info) return nativeFetch(input, init);
    const signal = (init && init.signal) || (input instanceof Request ? input.signal : undefined);
    return Promise.resolve(new Response(streamChunks(info, signal), {
      status: 200,
      headers: { 'Content-Type': info.type, 'Content-Length': String(info.size) },
    }));
  };
})();
