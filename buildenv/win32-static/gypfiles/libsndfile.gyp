{
	'targets': [
		{
			'target_name':  'libsndfile',
			'product_name': 'sndfile',
			'type':         'static_library',

			'msvs_settings': {
				'VCCLCompilerTool': {
					'EnableEnhancedInstructionSet': '4', # NoExtensions (/arch:IA32)
				},
			},

			'include_dirs': [
				'../src',
				'include',
				'include/x86',
				'<!(cygpath -w %MUMBLE_PREFIX%/sndfile/include)',
			],

			'defines': [
				'HAVE_CONFIG_H=1',

				'HAVE_EXTERNAL_LIBS=1',
				'FLAC__NO_DLL=1',

				'inline=__inline',
				'ssize_t=intptr_t',
				'__func__=__FUNCTION__'
			],

			'sources': [
				'../src/common.c',
				'../src/file_io.c',
				'../src/command.c',
				'../src/pcm.c',
				'../src/ulaw.c',
				'../src/alaw.c',
				'../src/float32.c',
				'../src/double64.c',
				'../src/ima_adpcm.c',
				'../src/ms_adpcm.c',
				'../src/gsm610.c',
				'../src/dwvw.c',
				'../src/vox_adpcm.c',
				'../src/interleave.c',
				'../src/strings.c',
				'../src/dither.c',
				'../src/broadcast.c',
				'../src/audio_detect.c',
				'../src/ima_oki_adpcm.c',
				'../src/ima_oki_adpcm.h',
				'../src/chunk.c',
				'../src/ogg.c',
				'../src/chanmap.c',
				'../src/windows.c',
				'../src/id3.c',

				'../src/sndfile.c',
				'../src/aiff.c',
				'../src/au.c',
				'../src/avr.c',
				'../src/caf.c',
				'../src/dwd.c',
				'../src/flac.c',
				'../src/g72xsf.c',
				'../src/htk.c',
				'../src/ircam.c',
				'../src/macbinary3.c',
				'../src/macos.c',
				'../src/mat4.c',
				'../src/mat5.c',
				'../src/nist.c',
				'../src/paf.c',
				'../src/pvf.c',
				'../src/raw.c',
				'../src/rx2.c',
				'../src/sd2.c',
				'../src/sds.c',
				'../src/svx.c',
				'../src/txw.c',
				'../src/voc.c',
				'../src/wve.c',
				'../src/w64.c',
				'../src/wav_w64.c',
				'../src/wav.c',
				'../src/xi.c',
				'../src/mpc2k.c',
				'../src/rf64.c',
				'../src/ogg_vorbis.c',
				'../src/ogg_speex.c',
				'../src/ogg_pcm.c',

				'../src/GSM610/add.c',
				'../src/GSM610/code.c',
				'../src/GSM610/decode.c',
				'../src/GSM610/gsm_create.c',
				'../src/GSM610/gsm_decode.c',
				'../src/GSM610/gsm_destroy.c',
				'../src/GSM610/gsm_encode.c',
				'../src/GSM610/gsm_option.c',
				'../src/GSM610/long_term.c',
				'../src/GSM610/lpc.c',
				'../src/GSM610/preprocess.c',
				'../src/GSM610/rpe.c',
				'../src/GSM610/short_term.c',
				'../src/GSM610/table.c',

				'../src/G72x/g721.c',
				'../src/G72x/g723_16.c',
				'../src/G72x/g723_24.c',
				'../src/G72x/g723_40.c',
				'../src/G72x/g72x.c',
			],
		},
		{
			'target_name':  'test_vsnprintf',
			'product_name': 'test_vsnprintf',
			'type':         'executable',

			'msvs_settings': {
				'VCCLCompilerTool': {
					'EnableEnhancedInstructionSet': '4', # NoExtensions (/arch:IA32)
				},
			},

			'dependencies':  [
				'libsndfile',
			],

			'defines': [
				'inline=__inline',
				'ssize_t=intptr_t',
				'__func__=__FUNCTION__'
			],

			'include_dirs': [
				'../src',
				'include',
				'include/x86',
				'<!(cygpath -w %MUMBLE_PREFIX%/sndfile/include)',
			],

			'sources': [
				'tests/test_vsnprintf.c'
			]
		}
	]
}