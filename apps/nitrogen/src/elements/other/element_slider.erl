-module (element_slider).
-compile(export_all).
-include_lib("wf.hrl").

reflect() -> record_info(fields, slider).

render_element(Record) ->

    % Get properties...
    Delegate = Record#slider.delegate,
    Tag = Record#slider.tag,
    Anchor = Record#slider.anchor,

    ChangePostbackInfo = wf_event:serialize_event_context({slider_change_event, Delegate, Tag}, Anchor, undefined, ?MODULE),

    SliderOptions = ?STRUCT([
        {value, Record#slider.value},
        {max, Record#slider.max},
        {min, Record#slider.min},
        {step, Record#slider.step},
        {disabled, Record#slider.disabled},
        {animate, Record#slider.animate},
        {range, Record#slider.range},
        {orientation, Record#slider.orientation},
        {values, Record#slider.values}
    ]),
    
    SliderScript = #script {
        script = wf:f("Nitrogen.$slider('~s', ~s, '~s');", [
            Anchor,
            ?JSON_ENCODE(SliderOptions),
            ChangePostbackInfo
        ])
    },
    wf:wire(SliderScript),

    % Render as a panel and hidden input element ...
    element_panel:render_element(#panel {
        anchor=Anchor,
        id=Record#slider.id,
        class=[slider, Record#slider.class],
        style=Record#slider.style,
        body=#hidden {
          id=Record#slider.id,
          text=wf:to_list(Record#slider.value)
        }
    }).

event({slider_change_event, Delegate, ChangeTag})->
    ChangeValue = ?JSON_DECODE(wf:q(change_value)),
    Module = wf:coalesce([Delegate, wf:page_module()]),
    Module:slider_change_event(ChangeValue, ChangeTag).

