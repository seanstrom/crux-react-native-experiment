import type { Dispatch, SetStateAction } from "react";
import type { Effect, Event } from "../shared_types/generated/typescript/types/shared_types";
import {
    EffectVariantRender,
    ViewModel,
    Request,
} from "../shared_types/generated/typescript/types/shared_types";
import {
    BincodeSerializer,
    BincodeDeserializer,
} from "../shared_types/generated/typescript/bincode/mod";

declare global {
    var processEvent: (payload: Uint8Array) => Uint8Array;
    var view: () => Uint8Array;
}


export function update(
    event: Event,
    callback: Dispatch<SetStateAction<ViewModel>>,
) {
    console.log("event", event);
    let process_event = global.processEvent

    const serializer = new BincodeSerializer();
    event.serialize(serializer);

    const effects = process_event(serializer.getBytes());

    const requests = deserializeRequests(effects);
    for (const { id, effect } of requests) {
        processEffect(id, effect, callback);
    }
}

function processEffect(
    _id: number,
    effect: Effect,
    callback: Dispatch<SetStateAction<ViewModel>>,
) {
    console.log("effect", effect);

    switch (effect.constructor) {
        case EffectVariantRender: {
            callback(deserializeView(view()));
            break;
        }
    }
}

function deserializeRequests(bytes: Uint8Array): Request[] {
    const deserializer = new BincodeDeserializer(bytes);
    const len = deserializer.deserializeLen();
    const requests: Request[] = [];
    for (let i = 0; i < len; i++) {
        const request = Request.deserialize(deserializer);
        requests.push(request);
    }
    return requests;
}

function deserializeView(bytes: Uint8Array): ViewModel {
    return ViewModel.deserialize(new BincodeDeserializer(bytes));
}
